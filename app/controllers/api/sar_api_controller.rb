class Api::SarApiController < ApplicationController
  respond_to :json

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

