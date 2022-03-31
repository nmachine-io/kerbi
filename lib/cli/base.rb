module Kerbi
  module Cli

    ##
    # Superclass for all Thor CLI handlers.
    class BaseHandler < Thor

      protected

      ##
      # Convenience method for printing dicts as YAML or JSON,
      # according to the CLI options.
      # @param [Hash|Array<Hash>] dicts
      def print_dicts(dicts)
        if self.cli_opts.outputs_yaml?
          printable_str = Kerbi::Utils::Cli.dicts_to_yaml(dicts)
        elsif self.cli_opts.outputs_json?
          printable_str = Kerbi::Utils::Cli.dicts_to_json(dicts)
        else
          raise "Unknown output format '#{cli_opts.output_format}'"
        end
        puts printable_str
      end

      ##
      # Returns single merged dict containing all values given or
      # pointed to by the CLI args, plus the default values.yaml file.
      # This includes values from files, inline expressions, and the
      # state ConfigMap.
      # @return [Hash] symbol-keyed dict of all loaded values
      def compile_values
        utils = Kerbi::Utils::Values
        file_values = utils.from_files(cli_opts.fname_exprs)
        inline_values = utils.from_inlines(cli_opts.inline_val_exprs)
        file_values.deep_merge(inline_values)
      end

      ##
      # Returns a re-usable instance of the CLI-args
      # wrapper Kerbi::CliOpts
      # @return [Kerbi::CliOpts] re-usable instance
      def cli_opts
        @_options_obj ||= Kerbi::CliOpts.new(self.options)
      end

      def state_manager
        # @_state_man
        if cli_opts.reads_state?
          case cli_opts.read_state_from
          when a
            puts "asd"
          else
            puts "asd"
          end
        end
      end

      ##
      # Convenience class method for declaring a Thor subcommand
      # metadata bundle, in accordance with the schema in
      # Kerbi::Consts::OptionSchemas.
      # @param [Hash] _schema a dict from Kerbi::Consts::OptionSchemas
      # @param [Class<Thor>] handler_cls the handler
      def self.thor_sub_meta(_schema, handler_cls)
        schema = _schema.deep_dup
        desc(schema[:name], schema[:desc])
        subcommand schema[:name], handler_cls
      end

      ##
      # Convenience class method for declaring a Thor command
      # metadata bundle, in accordance with the schema in
      # Kerbi::Consts::OptionSchemas.
      # @param [Hash] _schema a dict from Kerbi::Consts::OptionSchemas
      def self.thor_meta(_schema)
        schema = _schema.deep_dup
        desc(schema[:name], schema[:desc])
        (schema[:options] || []).each do |opt_schema|
          opt_key = opt_schema.delete(:key).to_sym
          self.option opt_key, opt_schema
        end
      end

      def self.exit_on_failure?
        true
      end

      private

      def utils
        Kerbi::Utils
      end
    end
  end
end
