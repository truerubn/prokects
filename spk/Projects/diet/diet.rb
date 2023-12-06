require 'tk'
require 'tkextlib/tile' # To access TkTtk::Tile::Progressbar

def scan_ports(host, from_port, to_port, result_text, progress_bar)
    open_ports = []
  
    total_ports = to_port - from_port + 1
    ports_scanned = 0
  
    (from_port..to_port).each do |port|
      begin
        socket = TCPSocket.new(host, port)
        open_ports << port
        socket.close
      rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
        next
      end
  
      ports_scanned += 1
  
      # Update progress bar
      progress_bar.value = (ports_scanned.to_f / total_ports * 100).to_i
      Tk.update
    end
  
    Tk.after(0) { result_text.insert('end', "Open ports: #{open_ports.join(', ')}\n") }
end  

root = TkRoot.new { title "Port Scanner" }


# (Previous code for labels, entries, and results_text remains unchanged)

progress_frame = TkFrame.new(root) {
  pack { padx 10; pady 5; side "left" }
}

progress_bar = TkTtk::Tile::Progressbar.new(progress_frame) {
  orient 'horizontal'
  length 200
  mode 'determinate'
  pack { padx 5; pady 5 }
}

scan_button = TkButton.new(root) do
  text "Start Scan"
  command do
    host = host_entry.get
    from_port = from_entry.get.to_i
    to_port = to_entry.get.to_i

    Thread.new do
      scan_ports(host, from_port, to_port, results_text, progress_bar)
    end
  end
  pack { padx 10; pady 5; side 'left' }
end

Tk.mainloop