require 'eventmachine'
require 'amqp'
require 'tlsmail'
require 'json'

class Email
	#class property
	@email_engine
	@from
	@password
	@to
	@subject
	@body

	def initialize
	end

	def prepare(to, subject, body)
		@from = 'no-reply@clodeo.com'
		@password = 'Noreply2012'
		@to = to
		@subject = subject

		@body = <<EOF
From: #{@from}
To: #{@to}
MIME-Version: 1.0
Content-type: text/html
Subject: #{@subject}
 
#{body}
EOF
	end

	def send_email(to, subject, body)
		prepare(to, subject, body)

		Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)  
		Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', @from, @password, :login) do |smtp| 
		  smtp.send_message(@body, @from, @to)
		end
	end
end

EventMachine.run do
    connection = AMQP.connect(:host => '127.0.0.1')
    email_sender = Email.new
    puts "Connecting to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    channel  = AMQP::Channel.new(connection)
    queue    = channel.queue("nodes.rb_email", :auto_delete => true)
    exchange = channel.default_exchange

    queue.subscribe do |payload|
    	settings = JSON.parse(payload)
    	email_sender.send_email(settings[:to], settings[:subject], settings[:body])
    end
end
