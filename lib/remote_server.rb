require 'net/ssh'
class RemoteServer
	def initialize(remote_ip, remote_port,username, password)
		@remote_ip = remote_ip
		@remote_port = remote_port
		@username = username
		@password = password
	end

	def remote_program_time(remote_full_path , parameters)
		Net::SSH.start(@remote_ip, @username, :password => @password) do |ssh|
			t1 = Time.now
			res = ssh.exec!("#{remote_full_path} #{parameters}")
			t2 = Time.now
			ssh.close
			puts (t2 - t1)*1000
		end
	end
end