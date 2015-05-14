class Api::SarApiController < ApplicationController
  respond_to :json
  
  def stats
    system("timeout #{params[:timeout]} docker stats #{params[:cvm_name]}", :out => ['/home/ritika/stats.txt', 'w'], :err => ['/tmp/log', 'a'])
    system("awk '{if(i++%2)print}' /home/ritika/stats.txt", :out => ['/home/ritika/stats2.txt', 'w'], :err => ['/tmp/log', 'a'])
    puts "hi"
    count = 0
    cpu = 0
    mem = 0 
    x = ""
    File.open("/home/ritika/stats2.txt", "r").readlines.each do |line|
         count = count + 1
         line = line.squish
         puts line
         words = line.split(' ')
         puts words[1] + " " + words[5]
         cpu += words[1].chomp('%').to_i
         mem += words[5].chomp('%').to_i
       end
    avgstats = {}   
    avgstats[:avgcpu] = cpu/count
    avgstats[:avgmem] = mem/count

    render json: avgstats
  end
  
  def cpu_stats
    execute_system_command("docker exec #{params[:cvm_name]} rm -f /tmp/sarfile")
    execute_system_command("docker exec #{params[:cvm_name]} sar -P ALL #{params[:time_interval1]} #{params[:time_interval2]} -o /tmp/sarfile > /dev/null")
    output = `docker exec #{params[:cvm_name]} sadf  -j /tmp/sarfile -P ALL #{params[:time_interval1]} #{params[:time_interval2]}`
    render json: output
  end

  def memory_stats
     execute_system_command("docker exec #{params[:cvm_name]} rm -f /tmp/sarfilememory")
     execute_system_command("docker exec #{params[:cvm_name]} sar -r #{params[:time_interval1]} #{params[:time_interval2]} -o /tmp/sarfilememory > /dev/null")
     output = `docker exec #{params[:cvm_name]} sadf  -j /tmp/sarfilememory -- -r #{params[:time_interval1]} #{params[:time_interval2]}`
     render json: output
   end

    def io_stats
      execute_system_command("docker exec #{params[:cvm_name]} rm -f /tmp/sarfileio")
      execute_system_command("docker exec #{params[:cvm_name]} sar -b #{params[:time_interval1]} #{params[:time_interval2]} -o /tmp/sarfileio > /dev/null")
      output = `docker exec #{params[:cvm_name]} sadf  -j /tmp/sarfileio -- -b #{params[:time_interval1]} #{params[:time_interval2]}`
      render json: output
    end

  protected

    def execute_system_command(command)
      Rails.logger.info("Executing #{command}")
      output = system command
      raise "Exception" if !output
    end
end

