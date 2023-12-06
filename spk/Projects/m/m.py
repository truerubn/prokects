from datetime import datetime
import json
import os
from time import sleep
import colorama

# Initialize colorama to work on Windows terminals
colorama.init()

# Clear the screen and display starting message
os.system("cls")
print(colorama.Fore.RED + "STARTING...")
sleep(3)
print(colorama.Fore.GREEN + "DONE")
sleep(1)
os.system("cls")

# Get JSON file(s)
jsonfiles = [file for file in os.listdir() if file.endswith(".json")]

for file in jsonfiles:
    with open(file, "r") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error loading user's JSON data: {e}")

# If there are more than one JSON files...
if len(jsonfiles) > 1:
    print("Program detected more than 1 user JSON file.")
    for index, file in enumerate(jsonfiles, start=1):
        print(f"{index}. {file}")
    
    # Select 1 to load.
    opt = input("Select the user via the number assigned: ")
    try:
        os.system("cls")
        selected_index = int(opt) - 1
        if 0 <= selected_index < len(jsonfiles):
            selected_jsonfile = jsonfiles[selected_index]
            print(f'PROCESSING FILE {selected_jsonfile}')

            with open(selected_jsonfile, 'r') as f:
                try:
                    data = json.load(f)
                except json.JSONDecodeError as e:
                    print(f'Error loading {selected_jsonfile}: {e}') 
        else:
            print('Invalid selection. Select a valid number')

    except ValueError:
        print("Invalid input. Please enter a number")

elif len(jsonfiles) == 1:
    with open(jsonfiles[0], 'r') as f:
        try:
            data = json.load(f)
            print(f"Processing {jsonfiles[0]}:")
            print(data)  # Print the content of the loaded JSON file
        except json.JSONDecodeError as e:
            print(f"Error loading {jsonfiles[0]}: {e}")

else:
    print("No JSON files found in the directory.")

# Define the periods for each day of the week
if "Student" in data and "Student_Name" in data["Student"]:
    STUDENT_NAME = data["Student"]["Student_Name"]
    print(colorama.Fore.CYAN + "Hello, " + STUDENT_NAME + ".")
    if "Classes" in data["Student"] and "Periods" in data["Student"]["Classes"]:
        ENROLLED_CLASSES = data["Student"]["Classes"]["Periods"]

        print(colorama.Fore.LIGHTYELLOW_EX + f"STUDENT \"{colorama.Back.LIGHTYELLOW_EX}{STUDENT_NAME}{colorama.Style.RESET_ALL}{colorama.Fore.LIGHTYELLOW_EX}\" ENROLLED SCHEDULE\n----------------------------")
        print(f'{ENROLLED_CLASSES}\n----------------------------')

# Retrieve periods for each day
PER1 = ENROLLED_CLASSES.get("Period 1", "")
PER2 = ENROLLED_CLASSES.get("Period 2", "")
PER3 = ENROLLED_CLASSES.get("Period 3", "")
PER4 = ENROLLED_CLASSES.get("Period 4", "")
PER5 = ENROLLED_CLASSES.get("Period 5", "")
PER6 = ENROLLED_CLASSES.get("Period 6", "")
PER7 = ENROLLED_CLASSES.get("Period 7", "")

# Define the lettered days and their corresponding periods
letter_days = {
    'A': [PER1, PER2, PER3, PER4, PER5], 
    'B': [PER6, PER7, PER1, PER2, PER3], 
    'C': [PER4, PER5, PER6, PER7, PER1], 
    'D': [PER2, PER3, PER4, PER5, PER6],
    'E': [PER7, PER1, PER2, PER3, PER4],
    'F': [PER5, PER6, PER7, PER1, PER2],
    'G': [PER3, PER4, PER5, PER6, PER7]
}

start_date = datetime(2023, month=9, day=2)  # Choose a starting date for your schedule
current_date = datetime.now()

# Calculate the number of days that have passed since the start date
days_passed = (current_date - start_date).days

# Calculate the cur2rent lettered day based on the number of days passed
number_of_lettered_days = len(letter_days)
current_lettered_day_index = days_passed % number_of_lettered_days
current_lettered_day = chr(ord('A') + current_lettered_day_index)

# Display the schedule for the current lettered day
if current_lettered_day in letter_days:
    print(colorama.Fore.LIGHTRED_EX + f"Today is {current_lettered_day} day. Periods today:")
    for period in letter_days[current_lettered_day]:
        print(f' • {period}')
else:
    print("No schedule available for today.")

# Reset colorama settings after usage
colorama.deinit()
