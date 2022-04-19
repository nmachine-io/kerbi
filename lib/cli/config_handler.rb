module Kerbi
  module Cli
    class ConfigHandler < BaseHandler

      cmd_meta Kerbi::Consts::CommandSchemas::CONFIG_LOCATION
      def location
        echo Kerbi::ConfigFile.file_path
      end

      cmd_meta Kerbi::Consts::CommandSchemas::CONFIG_SET
      def set(key, new_value)
        raise_if_bad_write(key)
        old_value = run_opts.options[key]
        Kerbi::ConfigFile.patch(key => new_value)

        name = "config[#{key}]"
        change_str = "from #{old_value} => #{new_value}"
        echo "Updated #{name} #{change_str}".colorize(:green)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::CONFIG_GET
      def get(key)
        echo run_opts.options[key]
      end

      cmd_meta Kerbi::Consts::CommandSchemas::CONFIG_SHOW
      def show
        src = run_opts.options
        hash = Hash[legal_keys.map { |k| [k, src[k]] }]
        echo_data(hash)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::CONFIG_RESET
      def reset
        Kerbi::ConfigFile.reset
        echo("Config reset".colorize(:green))
        echo("See #{Kerbi::ConfigFile.file_path}")
      end

      private

      def raise_if_bad_write(key)
        unless legal_keys.include?(key)
          raise Kerbi::IllegalConfigWrite.new(key)
        end
      end

      def legal_keys
        Kerbi::Consts::OptionKeys::LEGAL_CONFIG_FILE_KEYS
      end
    end
  end
end