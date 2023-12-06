require 'sinatra/base'
require 'faye/websocket'
require 'thin'

class ChatApp < Sinatra::Base
  get '/' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env)

      ws.on :message do |event|
        ws.send(event.data)
      end

      ws.on :close do |_event|
        ws = nil
      end

      ws.rack_response
    else
      erb :index
    end
  end

  run! if app_file == $0
end
