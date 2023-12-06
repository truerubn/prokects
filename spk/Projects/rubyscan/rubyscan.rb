require 'socket'
require 'colorize'
require 'optparse'

# constants

# these are the start and end port defaults
# when a -s or -e flag are specified or both
# the program result to these two consts.
DEFAULT_START_PORT = 1 
DEFAULT_END_PORT = 1000

# max threads for multi threading ( if you want to increase go ahead )
MAX_THREADS = 1000


# appendable variables
$open_ports = []
$closed_ports = []

def print_ascii_art
    ascii_art = <<-ART

                                        .::-::.:-=+######%#*+-    
                                :=*%%%%%%%%+:-+*%%%%%%%%%%%+. 
                            .-*%%%%%%%%%%%%%= .+%%%%%%%%%%%%#.
                        -*%%%%%%%%%%%%%%%%*  .:+%%%%%%%%%%%*
                        =%%%%%%%%%%%%%%%%%%%-=++***#%%%%%%%%%%
                    +%%%%%%%%%%%%%%%%%%%%*=####%%%%%%%%%%%%%
                    =%%%%%%%%%%%%%%%%%%%%%#:%%%%%%%%%%%%%%%%%#
                :#%%%%%%%%%%%%%%%%%%%%%* *%%%%%%%%%%%%%%%%%*
                =%%%%%%%%%%%%%%%%%%%%%%= -%%%%%%%%%%%%%%%@@@=
                *%%%%%%%%%%%%%%%%%%%%%#.  .%@%%%%%%%%%%%%%@@@-
            *@@@%%%%%%%%%%%%%%%%%#-.:---#@@@%%%%%%%%%%%@@@.
            =%%@@@@%%%%%%%%%%%%%#=-++++++*%@%%%%%%%%%%%@@@@ 
            #%%%%@@@@%%%%%%%%%#==**#######%%%%%%%%%%%%@@@@% 
            .+*#%%%%@@@@%%%%%+-+%%%%%%%%%%%%%%%%%%%%%%%@@@@* 
            .-=+*#%%%%@@@#+::*%%%%%%%%%%%%%%%%%%%%%%%%%@@@@+ 
            -*-:-=+*##*+-.  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%@@%- 
            +##.  ......:::+%%@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%: 
            *#%%=--=====+++%%%%@@@%%%%@@%%%%%%%%%%%%%%%%%%%%. 
            #%%%%*********%%%%%@@@@%%%%@@@@%%@%%%%%%%%%%%%%%  
            %%%%%%########%%%%@@@@%%%%@@@@@%%%%%%%%%%%%%%%%*  
            %%%%%%%#####%%%%%%@@@@%%%@@@@@%%%%%%%%%%%%%%%%%+  
            +%%%%%%%%%%%%%%%%@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%-  
            #%%%%%%%%%%%%%%%@@@@@@@%%%%%%%%%%%%%#######%%%:  
            +%%%%%%@@%%%%%@@@@%%%%%%%%%%%%%%%%%%%%##**+++.  
                :=**##%####***+++====---:::....               
                     888                                                   
                     888                                                   
                     888                                                   
    888d888 888  888 88888b.  888  888 .d8888b   .d8888b  8888b.  88888b.  
    888P"   888  888 888 "88b 888  888 88K      d88P"        "88b 888 "88b 
    888     888  888 888  888 888  888 "Y8888b. 888      .d888888 888  888 
    888     Y88b 888 888 d88P Y88b 888      X88 Y88b.    888  888 888  888 
    888      "Y88888 88888P"   "Y88888  88888P'  "Y8888P "Y888888 888  888 
                                   888                                     
                              Y8b d88P                                     
                               "Y88P"             
##############################################################################

    Developed by 
            rubn
                                                a rubn classic.

    ART
    puts ascii_art.colorize(:red)
  end
  
def loading_spinner(progress)
  Thread.new do
    spinner = %w[| / - \\]
    while progress < 100
      print "\rScanning... #{progress}% #{spinner[progress % 4]} "
      sleep(0.1)
    end
    puts "\rScanning... 100%"
  end
end

def port_scan(host, port)
  retry_count = 3
  begin
    socket = TCPSocket.new(host, port)
    socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, 3)
    puts "Port #{port} is open on #{host}!".green.underline.bold
    $open_ports << port # Capture open ports 
    socket.close
  rescue Errno::ECONNREFUSED
    puts "Port #{port} is closed on #{host}".red
    $closed_ports << port  # Capture closed ports
  rescue Errno::ETIMEDOUT => e
    if retry_count > 0
      retry_count -= 1
      puts "Connection timed out for port #{port} on #{host}, retrying...".red
      retry
    else
      puts "Connection timed out for port #{port} on #{host} after multiple attempts.".red
      $closed_ports << port  # Capture closed ports
    end
  rescue SocketError => e
    puts "Socket error occurred: #{e.message}".red
  rescue StandardError => e
    puts "An unexpected error occurred: #{e.message}".red
  end
end


def scan_range(num_threads, ip_range, start_port, end_port)
  queue = Queue.new
  ip_range.each { |host| (start_port..end_port).each { |port|  queue.push([host,port]) } }

  threads = []
  num_threads.times do 
    threads << Thread.new do
      while  task = queue.pop(true) rescue nil
        port_scan(*task)
      end
    end
  end

  threads.each(&:join)
end


def parse_options
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby your_script.rb [options] IP_RANGE"
  
      opts.on("-sSTART_PORT", "--start=START_PORT", Integer, "Specify start port") do |start_port|
        options[:start_port] = start_port
      end
  
      opts.on("-eEND_PORT", "--end=END_PORT", Integer, "Specify end port") do |end_port|
        options[:end_port] = end_port
      end
  
      opts.on("-h", "--help", "Prints this help") do
        print_ascii_art
        puts opts
        exit
      end
    end.parse!
  
    options
  end

  begin
    options = parse_options
  
    print_ascii_art
  
    if ARGV.empty?
      puts "Usage ->".colorize(:black).on_red + " " + "ruby e.rb [options] IPRANGE".underline + "\n\n" + "Confused? type this command: rubyscan -h".colorize(:black).on_red
      exit(1)
    end
  
    ip_range = ARGV[0].split(',')
  start_port = options[:start_port] || DEFAULT_START_PORT
  end_port = options[:end_port] || DEFAULT_END_PORT
  num_threads = MAX_THREADS # Not adding flag because it's gay

  start_time = Time.now

  scan_range(num_threads, ip_range, start_port, end_port)

  end_time = Time.now
  elapsed_time = end_time - start_time

  # Write open ports and their hosts to a file
  File.open('scanresult.lst', 'w') do |file|
    $open_ports.each do |port|
      file.puts("Host: #{ip_range[0]} | Port: #{port} | Status: Open")
    end
  end

  # Display the count of open and closed ports
  puts '-' * 34
  puts "            SCAN RESULTS"
  puts '-' * 34
  puts "  OPEN PORTS     | #{$open_ports.count.to_s.colorize(:green)}"
  puts "  CLOSED PORTS   | #{$closed_ports.count.to_s.colorize(:red)}"
  puts "\n  ELAPSED SCAN TIME | #{elapsed_time.round(2).to_s.colorize(:cyan)} sec"
rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
  puts "Error: #{e.message}"
  puts "Usage: ruby your_script.rb [options] IP_RANGE"
  exit(1)
rescue => e
  puts "An unexpected error occurred: #{e.message}"
  exit(1)
end