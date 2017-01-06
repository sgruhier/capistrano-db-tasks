require 'pry'
module Capistrano
  module DbTasks
    module Databases
      class Base
        DBCONFIG_BEGIN_FLAG = "__CAPISTRANODB_CONFIG_BEGIN_FLAG__".freeze
        DBCONFIG_END_FLAG = "__CAPISTRANODB_CONFIG_END_FLAG__".freeze

        DBCONFIG_RAILS_CMD = %(puts '#{DBCONFIG_BEGIN_FLAG}'+ActiveRecord::Base.connection.instance_variable_get(:@config).to_yaml+'#{DBCONFIG_END_FLAG}').freeze

        attr_accessor :adapter, :cap, :compressor, :config

        def initialize(cap_instance)
          @cap = cap_instance
          load_config!
          load_adapter!
          load_compressor!
        end

        def load_compressor!
          @compressor ||= begin
                            compressor_klass = @cap.fetch(:compressor).to_s.split('_').collect(&:capitalize).join
                            klass = Object.module_eval("::Capistrano::DbTasks::Compressors::#{compressor_klass}", __FILE__, __LINE__)
                            klass
                          end
        end

        def output_file
          @output_file ||= "#{config['database']}_#{current_time}.sql.#{compressor.file_extension}"
        end

        def load_config!
          raise "Only in Local or Remote"
        end

        def available_adapters
          @available_adapters ||= Capistrano::DbTasks::Adapters.constants.map { |c| Capistrano::DbTasks::Adapters.const_get(c) }.select { |c| c.is_a? Class }
        end

        def load_adapter!
          adapter_klass = available_adapters.find { |a| a.suitable? config["adapter"] }

          raise "Only #{avaliable_adapters.map(&:to_s).join(', ')} on remote and local server is supported" unless adapter_klass

          @adapter = adapter_klass.new
          @adapter.cap = @cap
          @adapter.config = @config

          @adapter
        end

        private

        def run_locally(command)
          stdout, status = Open3.capture2(command)

          raise "Error running command locally (status=#{status}): #{command}" if status != 0

          stdout
        end

        def current_time
          Time.now.strftime("%Y-%m-%d-%H%M%S")
        end
      end
    end
  end
end
