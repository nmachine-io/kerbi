module Kerbi
  module Cli
    class ConfigHandler < BaseHandler

      thor_meta Kerbi::Consts::CommandSchemas::CONFIG_LOCATION
      def location
        puts Kerbi::ConfigFile.file_path
      end

      thor_meta Kerbi::Consts::CommandSchemas::CONFIG_SET
      def set(key, value)
        raise_if_bad_write(key)
        Kerbi::ConfigFile.patch(key => value)
      end

      thor_meta Kerbi::Consts::CommandSchemas::CONFIG_GET
      def get(key)
        puts run_opts.options[key]
      end

      thor_meta Kerbi::Consts::CommandSchemas::CONFIG_SHOW
      def show
        echo_data(run_opts.options)
      end

      private

      def raise_if_bad_write(key)
        unless legal_keys.include?(key)
          raise Kerbi::IllegalConfigWrite
        end
      end

      def legal_keys
        Kerbi::Consts::OptionKeys::LEGAL_CONFIG_FILE_KEYS
      end
    end
  end
end