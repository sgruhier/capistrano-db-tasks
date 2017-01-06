module Capistrano
  module DbTasks
    module Adapters
      class Base
        attr_accessor :cap, :config

        def self.suitable?(adapter); end

        def database
          @config['database']
        end

        def dump_cmd
          raise "Dump database is not implemented"
        end

        def import_cmd
          raise "Import database is not implemented"
        end
      end
    end
  end
end
