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
				@password = 'No-reply2013'
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
