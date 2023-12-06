require 'json'
require 'colorize'

# Clear the screen and display starting message
system("cls")
puts "STARTING...".colorize(:red)
sleep(3)
puts "DONE".colorize(:green)
sleep(1)
system("cls")

# Get JSON file(s)
jsonfiles = Dir.glob("*.json")

jsonfiles.each do |file|
  begin
    data = JSON.parse(File.read(file))
  rescue JSON::ParserError => e
    puts "Error loading user's JSON data: #{e}"
  end
end

# make a new ENROLLED_CLASSES var ( Hopefully fixing the ".key? undefined" error )
# ENROLLED_CLASSES = {} it did not

# If there are more than one JSON files...
if jsonfiles.length > 1
  puts "Program detected more than 1 user JSON file."
  jsonfiles.each_with_index do |file, index|
    puts "#{index + 1}. #{file}"
  end
  
  # Select 1 to load.
  print "Select the user via the number assigned: "
  opt = gets.chomp.to_i
  system("cls")

  if (1..jsonfiles.length).include?(opt)
    selected_jsonfile = jsonfiles[opt - 1]
    puts "PROCESSING FILE #{selected_jsonfile}"

    begin
      data = JSON.parse(File.read(selected_jsonfile))
    rescue JSON::ParserError => e
      puts "Error loading #{selected_jsonfile}: #{e}"
    end
  else
    puts 'Invalid selection. Select a valid number'
  end
elsif jsonfiles.length == 1
  begin
    data = JSON.parse(File.read(jsonfiles[0]))
    puts "Processing #{jsonfiles[0]}:"
    puts data  # Print the content of the loaded JSON file
  rescue JSON::ParserError => e
    puts "Error loading #{jsonfiles[0]}: #{e}"
  end
else
  puts "No JSON files found in the directory."
end

# Define the periods for each day of the week
if data.key?("Student") && data["Student"].is_a?(Hash) && data["Student"].key?("Student_Name")
  STUDENT_NAME = data["Student"]["Student_Name"]
  puts "Hello, #{STUDENT_NAME.colorize(:cyan)}"
  
  if data["Student"].key?("Classes") && data["Student"]["Classes"].is_a?(Hash) && data["Student"]["Classes"].key?("Periods")
    ENROLLED_CLASSES = data["Student"]["Classes"]["Periods"]

    puts "STUDENT \"#{STUDENT_NAME.colorize(:light_yellow)}\" ENROLLED SCHEDULE\n----------------------------"
    puts "#{ENROLLED_CLASSES}\n----------------------------"
  else
    puts "No enrolled classes found."
  end
else
  puts "Student data or student name not found."
end


# Retrieve periods for each day
PER1 = ENROLLED_CLASSES&.fetch("Period 1", "")
PER2 = ENROLLED_CLASSES&.fetch("Period 2", "")
PER3 = ENROLLED_CLASSES&.fetch("Period 3", "")
PER4 = ENROLLED_CLASSES&.fetch("Period 4", "")
PER5 = ENROLLED_CLASSES&.fetch("Period 5", "")
PER6 = ENROLLED_CLASSES&.fetch("Period 6", "")
PER7 = ENROLLED_CLASSES&.fetch("Period 7", "")

# Define the lettered days and their corresponding periods
letter_days = {
  'A' => [PER1, PER2, PER3, PER4, PER4],
  'B' => [PER6, PER7, PER1, PER2, PER3],
  'C' => [PER4, PER5, PER6, PER7, PER1],
  'D' => [PER2, PER3, PER4, PER4, PER6],
  'E' => [PER7, PER1, PER2, PER3, PER4],
  'F' => [PER4, PER6, PER7, PER1, PER2],
  'G' => [PER3, PER4, PER4, PER6, PER7]
}

start_date = Time.new(2023, 9, 2)  # Choose a starting date for your schedule ( This should be updated if there is a break )
current_date = Time.now            #                                            Idea: auto update via data from calendar

# Calculate the number of days that have passed since the start date
days_passed = (current_date - start_date) / (24 * 60 * 60)

# Calculate the current lettered day based on the number of days passed
number_of_lettered_days = letter_days.length
current_lettered_day_index = days_passed.to_i % number_of_lettered_days
current_lettered_day = ('A'.ord + current_lettered_day_index).chr

# Display the schedule for the current lettered day
if data
  student = data['Student']
  student_name = student['Student_Name']
  puts "Hello, #{student_name.colorize(:cyan)}"
  puts "STUDENT \"#{student_name.colorize(:light_yellow)}\" ENROLLED SCHEDULE"
  puts "------------------------------------------------------------"

  periods = student['Classes']['Periods']
  periods.each do |period, details|
    subject = details['Subject']
    teacher = details['Teacher']
    building = details['Location']['Building']
    room_number = details['Location']['RoomNumber']

    puts "#{period}:"
    puts "  Subject: #{subject}"
    puts "  Teacher: #{teacher}"
    puts "  Location: #{building}, Room #{room_number}"
    puts "------------------------------------------------------------"
  end

  # Retrieve today's schedule
  today = Time.now.strftime("%A")
  today_schedule = student['Classes']['Periods']["Period #{today[0]}"]
  if today_schedule
    puts "Today's Schedule (#{today}):"
    puts "  Subject: #{today_schedule['Subject']}"
    puts "  Teacher: #{today_schedule['Teacher']}"
    puts "  Location: #{today_schedule['Location']['Building']}, Room #{today_schedule['Location']['RoomNumber']}"
  else
    puts "No schedule available for today."
  end
else
  puts "No valid data found."
end