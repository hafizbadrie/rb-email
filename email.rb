require 'tlsmail'

class Email
	#class property
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

email_sender = Email.new
email_sender.send_email('hafizbadrie@gmail.com', 'Test Ruby Email Class', '<h1>This is cool bro!</h1><br>Now you can see it in HTML.')