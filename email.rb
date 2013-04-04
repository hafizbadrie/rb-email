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

	def prepare(engine, to, subject, body)
		@email_engine = engine
		case @email_engine
			when 'cardtopost'
				@from = 'noreply@cardtopost.com'
				@password = 'Noreply2013'
			else
				@from = 'no-reply@clodeo.com'
				@password = 'Noreply2012'
			end
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

	def send_email(engine, to, subject, body)
		prepare(engine, to, subject, body)

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
    	puts "Received a message: #{payload}"
    	settings = JSON.parse(payload)
    	email_sender.send_email(settings["engine"], settings["to"], settings["subject"], settings["body"])
    end
end
