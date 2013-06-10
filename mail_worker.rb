require 'eventmachine'
require 'amqp'
require './email'

EventMachine.run do
    connection = AMQP.connect(:host => '127.0.0.1')
    email_sender = Email.new
    puts "Connecting to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("nodes.fanout.mail")
    queue    = channel.queue("nodes.rb_email", :auto_delete => true).bind(exchange)

    queue.subscribe do |payload|
    	puts "Received a message: #{payload}"
    	settings = JSON.parse(payload)
    	puts "ENGINE : " + settings["engine"]
        begin
    	   email_sender.send_email(settings["engine"], settings["to"], settings["subject"], settings["body"])
        rescue
            puts "Error in sending..."
        end
    end
end