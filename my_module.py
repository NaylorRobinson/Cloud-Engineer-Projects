# ═══════════════════════════════════════════════════════════════
#  my_module.py
#  This is our custom Python module for Task 7
#  A module is just a .py file with functions that other files can import
#  Keep this file in the SAME folder as python_basics.py
# ═══════════════════════════════════════════════════════════════

# This is the function our module provides
# When python_basics.py does "import my_module" it gets access to this
def say_hello(name):
    """
    This function takes a name and returns a greeting string.
    The triple quotes above are called a docstring — they describe what the function does.
    """
    # Build a greeting message and return it
    return f"Hello from my_module, {name}! Modules help keep code organized."
