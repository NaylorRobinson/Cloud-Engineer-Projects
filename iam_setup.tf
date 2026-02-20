# ═══════════════════════════════════════════════════════════════
#  IAM COMPLETE SETUP — Users, Groups, Roles, Policies, MFA
#  This script creates everything you need for your IAM assignment
# ═══════════════════════════════════════════════════════════════

# ── PROVIDER ────────────────────────────────────────────────────
# This tells Terraform we are using AWS and which version to use
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This sets the AWS region where everything will be created
provider "aws" {
  region = "us-east-1"
}

# ════════════════════════════════════════════════════════════════
#  SECTION 1 — IAM USER
#  An IAM user is like a login account inside your AWS account.
#  You can give it permissions to do specific things.
# ════════════════════════════════════════════════════════════════

# Create the IAM user — this is the actual user account
resource "aws_iam_user" "student_user" {
  name = "student-user"   # The username that will appear in AWS

  # This tag helps you identify the user in the AWS console
  tags = {
    Name = "student-user"
    Purpose = "IAM Assignment"
  }
}

# Give the user CONSOLE access (so they can log into the AWS website)
# This creates a password for the user to log in with
resource "aws_iam_user_login_profile" "student_user_login" {
  user                    = aws_iam_user.student_user.name
  password_reset_required = true   # Forces user to change password on first login
}

# Give the user PROGRAMMATIC access (so they can use AWS CLI & APIs)
# This creates an Access Key ID and Secret Access Key
resource "aws_iam_access_key" "student_user_key" {
  user = aws_iam_user.student_user.name
}

# Attach a built-in AWS policy directly to the user
# AmazonS3ReadOnlyAccess = user can VIEW S3 buckets but NOT delete or modify them
resource "aws_iam_user_policy_attachment" "student_s3_readonly" {
  user       = aws_iam_user.student_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# ════════════════════════════════════════════════════════════════
#  SECTION 2 — IAM GROUPS
#  Groups let you manage permissions for multiple users at once.
#  Instead of setting permissions per user, you set them on the group.
# ════════════════════════════════════════════════════════════════

# --- Admins Group ---
# This group is for admin users who need full EC2 access
resource "aws_iam_group" "admins" {
  name = "Admins"
}

# Attach EC2FullAccess to the Admins group
# This means everyone in Admins can do ANYTHING with EC2 instances
resource "aws_iam_group_policy_attachment" "admins_ec2_full" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# --- Developers Group ---
# This group is for developers who need broad but not full admin access
resource "aws_iam_group" "developers" {
  name = "Developers"
}

# Attach PowerUserAccess to the Developers group
# PowerUserAccess = can do almost everything EXCEPT manage IAM users/groups
resource "aws_iam_group_policy_attachment" "developers_poweruser" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Add the student user to the Developers group
# This gives the user all the permissions the Developers group has
resource "aws_iam_user_group_membership" "student_group_membership" {
  user = aws_iam_user.student_user.name

  groups = [
    aws_iam_group.developers.name   # Add to Developers group
  ]
}


# ════════════════════════════════════════════════════════════════
#  SECTION 3 — IAM ROLE
#  Roles are like permission badges you pin onto AWS services.
#  Instead of giving a user access, you give an EC2 instance
#  a role so it can talk to other AWS services automatically.
# ════════════════════════════════════════════════════════════════

# The "assume role policy" defines WHO can use this role
# Here we say: EC2 instances are allowed to use this role
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

  # This JSON tells AWS that EC2 is allowed to assume (wear) this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"       # The action that allows role assumption
        Effect    = "Allow"                # We are ALLOWING it
        Principal = {
          Service = "ec2.amazonaws.com"    # Only EC2 instances can use this role
        }
      }
    ]
  })

  tags = {
    Name = "ec2-s3-access-role"
  }
}

# Attach S3FullAccess to the role
# This means any EC2 instance wearing this role can do ANYTHING with S3
resource "aws_iam_role_policy_attachment" "ec2_s3_full" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# An instance profile is a container that lets you attach a role to an EC2 instance
# Think of it as the holder that carries the role badge for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# Launch an EC2 instance with the role attached
# This EC2 instance will automatically have S3FullAccess via the role
resource "aws_instance" "iam_demo_ec2" {
  ami                  = "ami-04b4f1a9cf54c11d0"   # Ubuntu 22.04 LTS in us-east-1
  instance_type        = "t2.micro"                 # Free tier eligible
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name  # Attach the role

  # This script runs when the EC2 starts up
  # It lists all S3 buckets to prove the role permissions are working
  user_data = base64encode(join("\n", [
    "#!/bin/bash",
    "# Install AWS CLI so we can test the role permissions",
    "apt-get update -y",
    "apt-get install -y awscli",
    "# List all S3 buckets — this proves the role's S3 permissions work",
    "# The output will be saved to a file you can cat to see it",
    "aws s3 ls > /home/ubuntu/s3_bucket_list.txt 2>&1",
    "echo 'Role test complete. Check /home/ubuntu/s3_bucket_list.txt'",
  ]))

  tags = {
    Name = "iam-demo-ec2"
  }
}


# ════════════════════════════════════════════════════════════════
#  SECTION 4 — CUSTOM IAM POLICY
#  Instead of using a built-in AWS policy, here we WRITE our own.
#  This gives us fine-grained control over exactly what is allowed.
# ════════════════════════════════════════════════════════════════

# Create an S3 bucket to use in our custom policy demo
resource "aws_s3_bucket" "demo_bucket" {
  bucket        = "iam-demo-bucket-${random_id.bucket_suffix.hex}"  # Unique name
  force_destroy = true   # Allows Terraform to delete it even if it has files

  tags = {
    Name = "iam-demo-bucket"
  }
}

# Random ID to make the S3 bucket name unique (bucket names must be globally unique)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# This is our CUSTOM policy — written in JSON
# It grants ReadOnly access to ONLY our specific S3 bucket
# Nothing else — not all of S3, just this one bucket
resource "aws_iam_policy" "custom_s3_readonly" {
  name        = "CustomS3ReadOnlyPolicy"
  description = "Read-only access to the specific IAM demo S3 bucket only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow the user to see the bucket exists
        Sid      = "AllowListBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.demo_bucket.arn]   # Only THIS bucket
      },
      {
        # Allow the user to read/download files from the bucket
        Sid      = "AllowGetObjects"
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",      # Download files
          "s3:GetObjectVersion" # See file versions
        ]
        Resource = ["${aws_s3_bucket.demo_bucket.arn}/*"]  # All files inside the bucket
      }
    ]
  })
}

# Attach the custom policy to our student user
# Now the student user has ReadOnly access to just that one S3 bucket
resource "aws_iam_user_policy_attachment" "student_custom_policy" {
  user       = aws_iam_user.student_user.name
  policy_arn = aws_iam_policy.custom_s3_readonly.arn
}


# ════════════════════════════════════════════════════════════════
#  SECTION 5 — MFA (Multi-Factor Authentication)
#  MFA adds a second layer of security. Even if someone steals
#  your password, they still can't log in without your phone.
#  NOTE: Terraform can CREATE the MFA device but the actual
#  phone setup must be done manually in the AWS Console.
#  Instructions are printed in the outputs below.
# ════════════════════════════════════════════════════════════════

# Create a virtual MFA device for the student user
# This generates a QR code you scan with Google Authenticator or Authy
resource "aws_iam_virtual_mfa_device" "student_mfa" {
  virtual_mfa_device_name = "student-user-mfa"   # Name for the MFA device

  tags = {
    Name = "student-user-mfa"
  }
}


# ════════════════════════════════════════════════════════════════
#  OUTPUTS — Info printed after terraform apply finishes
#  These are the values you'll need for your screenshots
# ════════════════════════════════════════════════════════════════

# Print the IAM username
output "iam_username" {
  description = "The IAM username created"
  value       = aws_iam_user.student_user.name
}

# Print the Access Key ID (safe to show)
output "access_key_id" {
  description = "Programmatic access key ID for the IAM user"
  value       = aws_iam_access_key.student_user_key.id
}

# Print the Secret Access Key — marked sensitive so it doesn't show in logs
output "secret_access_key" {
  description = "Secret access key — save this, it won't be shown again!"
  value       = aws_iam_access_key.student_user_key.secret
  sensitive   = true   # Hides it from terminal output for security
}

# Print the EC2 instance public IP so you can SSH in
output "ec2_public_ip" {
  description = "Public IP of the IAM demo EC2 instance"
  value       = aws_instance.iam_demo_ec2.public_ip
}

# Print the S3 bucket name
output "s3_bucket_name" {
  description = "Name of the demo S3 bucket used in custom policy"
  value       = aws_s3_bucket.demo_bucket.bucket
}

# Print the MFA device ARN and setup instructions
output "mfa_setup_instructions" {
  description = "Steps to complete MFA setup"
  value       = <<-MSG
    ─────────────────────────────────────────────
    MFA SETUP — Complete these steps manually:
    1. Go to AWS Console → IAM → Users → student-user
    2. Click the 'Security credentials' tab
    3. Under 'Multi-factor authentication (MFA)' click 'Assign MFA device'
    4. Choose 'Authenticator app'
    5. Scan the QR code with Google Authenticator or Authy on your phone
    6. Enter two consecutive codes from the app to confirm
    7. Take your screenshot on the confirmation page
    ─────────────────────────────────────────────
  MSG
}

# Print role verification instructions
output "role_verification_instructions" {
  description = "How to verify the EC2 role is working"
  value       = <<-MSG
    ─────────────────────────────────────────────
    ROLE VERIFICATION — SSH into your EC2 and run:
    cat /home/ubuntu/s3_bucket_list.txt
    This shows all your S3 buckets, proving the role works!
    ─────────────────────────────────────────────
  MSG
}
