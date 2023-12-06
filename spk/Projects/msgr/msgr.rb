require 'socket'
require 'openssl'

# Generate a key for Client A
client_key = OpenSSL::Cipher.new('AES-256-CBC').random_key

receiver_port = 2001 # Port number for receiving messages
receiver = TCPServer.new(receiver_port)

print "Enter the receiver's IP address: "
receiver_ip = gets.chomp
receiver_port = 2002 # Port number for sending messages

# Create a separate thread for receiving messages
receive_thread = Thread.new do
  loop do
    sender = receiver.accept
    encrypted_message = sender.gets.chomp
    sender.close

    def decrypt_message(encrypted_msg, key)
      decipher = OpenSSL::Cipher.new('AES-256-CBC')
      decipher.decrypt
      decipher.key = key
      decipher.update(encrypted_msg) + decipher.final
    rescue OpenSSL::Cipher::CipherError => e
      puts "Decryption failed: #{e.message}"
    end

    decrypted_message = decrypt_message(encrypted_message, client_key)
    puts "Received encrypted message: #{encrypted_message}"
    puts "Decrypted message: #{decrypted_message}"
  end
end

# Send messages
loop do
  receiver_sender = TCPSocket.new(receiver_ip, receiver_port)

  print "Enter the message to send: "
  msg_to_send = gets.chomp

  def encrypt_message(msg, key)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = key
    encrypted = cipher.update(msg) + cipher.final
    encrypted
  end

  encrypted_message = encrypt_message(msg_to_send, client_key)
  receiver_sender.puts encrypted_message
  receiver_sender.close
end
