# ═══════════════════════════════════════════════════════════════
#  PYTHON BASICS ASSIGNMENT
#  Run this file with: python3 python_basics.py
# ═══════════════════════════════════════════════════════════════


# ════════════════════════════════════════════════════════════════
#  TASK 1 — Basic Syntax Practice
#  print() is the most basic Python function
#  It outputs text to the terminal
# ════════════════════════════════════════════════════════════════

print("Task 1: Basic Syntax")

# print() takes whatever is inside the quotes and displays it
print("My name is Naylor")
print("I am 42 years old")


# ════════════════════════════════════════════════════════════════
#  TASK 2 — Variables and Data Types
#  Variables are containers that store values
#  str = text, int = whole number, bool = True or False
# ════════════════════════════════════════════════════════════════

print("\n===== Task 2: Variables and Data Types =====")

# str (string) = text data, always wrapped in quotes
name = "Naylor"

# int (integer) = whole number, no quotes needed
age = 42

# bool (boolean) = only two possible values: True or False
likes_python = True

# f-string lets you put variables directly inside a print statement
# the f before the quote and {} around the variable name is the syntax
print(f"Name: {name}")
print(f"Age: {age}")
print(f"Likes Python: {likes_python}")


# ════════════════════════════════════════════════════════════════
#  TASK 3 — Lists and Dictionaries
#  List = ordered collection of items, uses square brackets []
#  Dictionary = key-value pairs, like a real dictionary (word: definition)
# ════════════════════════════════════════════════════════════════

print("\n===== Task 3: Lists and Dictionaries =====")

# A list stores multiple items in order
# Access items by index — first item is index 0
favorite_fruits = ["mango", "strawberry", "watermelon"]

# A dictionary stores data as key: value pairs
# Like a mini database record
person = {
    "name": "Naylor",   # key is "name", value is "Alex"
    "age": 42         # key is "age", value is 20
}

print("Favorite fruits:", favorite_fruits)
print("Person dictionary:", person)

# You can also access individual items like this:
print("First fruit:", favorite_fruits[0])   # index 0 = first item
print("Name from dict:", person["name"])     # access by key name


# ════════════════════════════════════════════════════════════════
#  TASK 4 — Conditional Statements
#  if/elif/else lets your program make decisions
#  Python checks each condition top to bottom and runs the first True one
# ════════════════════════════════════════════════════════════════

print("\n===== Task 4: Conditional Statements =====")

number = 7   # change this number to test different outcomes

# if checks the first condition
if number > 0:
    print(f"{number} is positive")

# elif (else if) checks another condition if the first was False
elif number < 0:
    print(f"{number} is negative")

# else runs if ALL conditions above were False
else:
    print(f"{number} is zero")


# ════════════════════════════════════════════════════════════════
#  TASK 5 — Loops
#  Loops let you repeat code without writing it over and over
#  for loop = runs a set number of times
#  while loop = keeps running UNTIL a condition becomes False
# ════════════════════════════════════════════════════════════════

print("\n===== Task 5: Loops =====")

# for loop — loops through each letter in the name string one by one
print("Letters in my name:")
for letter in name:          # name = "Alex" from Task 2
    print(letter)            # prints A, then l, then e, then x

# while loop — keeps going as long as the condition is True
print("Counting 1 to 5:")
count = 1                    # start at 1
while count <= 5:            # keep going while count is 5 or less
    print(count)
    count += 1               # count += 1 means add 1 each time (prevents infinite loop!)


# ════════════════════════════════════════════════════════════════
#  TASK 6 — Functions
#  A function is a reusable block of code
#  def = keyword to define a function
#  return = sends a value back to whoever called the function
# ════════════════════════════════════════════════════════════════

print("\n===== Task 6: Functions =====")

# Define the function — this doesn't run it yet, just creates it
def add_numbers(num1, num2):   # num1 and num2 are parameters (inputs)
    result = num1 + num2       # add the two numbers together
    return result              # send the result back

# Call the function — this actually runs it
# We pass in 15 and 25 as the arguments
total = add_numbers(15, 25)
print(f"The sum of 15 and 25 is: {total}")


# ════════════════════════════════════════════════════════════════
#  TASK 7 — Modules
#  A module is just a separate Python file with functions in it
#  import lets you bring in code from another file or Python's library
#  See the file my_module.py for the module we are importing below
# ════════════════════════════════════════════════════════════════

print("\n===== Task 7: Modules =====")

# Import our custom module (my_module.py must be in the same folder)
import my_module

# Call the function from our module
greeting = my_module.say_hello("Naylor")
print(greeting)

# We can also import built-in Python modules
# math is a built-in module that comes with Python
import math
print(f"Pi is: {math.pi}")
print(f"Square root of 16 is: {math.sqrt(16)}")
