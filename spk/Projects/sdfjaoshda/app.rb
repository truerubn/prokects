require 'sinatra'
require 'json'

ERR = '{!}'
OK = '{+}'
IMP = '{~}'

def get_active_tools(file)
  begin
    data = JSON.parse(File.read(file))

    if data.key?('User') && data['User'].key?('Tools')
      tools_with_status = data['User']['Tools']
      active_tools = tools_with_status.select { |_, status| status == 'ACTIVE' }.keys
      puts "Active Tools found: #{active_tools}"
      return active_tools
    else
      puts "#{IMP} ERROR: JSON does NOT contain 'User' or 'Tools'"
      return []  # Return an empty array if tools are not found
    end
  rescue JSON::JSONError => e
    puts "#{ERR} JSON Error: #{e}"
    return []  # Return an empty array if there's a JSON parsing error
  rescue StandardError => e
    puts "#{ERR} Error: #{e}"
    return []  # Return an empty array if there's a general error
  end
end

file_path = File.expand_path('tools/tools.json', __dir__)

active_tools = get_active_tools(file_path)
puts "#{IMP} ACTIVE TOOLS:: #{active_tools}"

get '/' do
  erb :index, locals: { tools: active_tools }
end

post '/run_tool' do
  tool = params[:tool]
  puts "Received tool: #{tool}"  # Debugging output

  if active_tools.include?(tool)
    case tool
    when 'wireshark'
      system('start wireshark')
      "Started Wireshark"
    when 'zenmap'
      system('start zenmap')
      "Started Zenmap"
    when 'nmap'
      system('start cmd /k nmap')
      "Started nmap in Command Prompt"
    when 'john'
      system('start cmd /k john')
      "Started John the Ripper in Command Prompt"
    else
      'Unknown tool!'
    end
  else
    "Tool '#{tool}' is not active or unknown!"
  end
end