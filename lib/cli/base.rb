module Kerbi
  module Cli

    ##
    # Superclass for all Thor CLI handlers.
    class BaseHandler < Thor

      protected

      def resolve_serializer(options={})
        if cli_opts.outputs_json?
          winner = options[:json_serializer]
        elsif cli_opts.outputs_yaml?
          winner = options[:yaml_serializer]
        elsif cli_opts.outputs_table?
          winner = options[:table_serializer]
        else
          raise "Unknown output format '#{cli_opts.output_format}'"
        end
        winner || options[:serializer]
      end

      ##
      # Convenience method for printing dicts as YAML or JSON,
      # according to the CLI options.
      # @param [Hash|Array<Hash>] dicts
      def echo_data(items, **opts)
        utils = Kerbi::Utils::Cli
        serializer = resolve_serializer(opts)
        items = utils.coerce_hash_or_array(items, opts)
        if serializer
          if items.is_a?(Array)
            items = items.map{ |e| serializer.new(e).serialize}
          else
            items = serializer.new(items).serialize
          end
        end

        if self.cli_opts.outputs_yaml?
          printable_str = utils.dicts_to_yaml(items)
        elsif self.cli_opts.outputs_json?
          printable_str = utils.dicts_to_json(items)
        elsif self.cli_opts.outputs_table?
          printable_str = utils.list_to_table(items, serializer)
        else
          raise "Unknown output format '#{cli_opts.output_format}'"
        end

        puts printable_str
      end

      # @param [Kube::State::Entry] entry
      def print_describe(entry)
        data = serializer_cls.new(entry).serialize
        puts data
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
        defaults = schema[:defaults]
        (schema[:options] || []).each do |opt_schema|
          thor_option(opt_schema, defaults)
        end
      end

      def self.thor_option(opt_schema, defaults)
        opt_key = opt_schema.delete(:key).to_sym

        final_defaults = defaults || Kerbi::Consts::OptionDefaults::BASE

        if final_defaults.has_key?(opt_key.to_s)
          opt_schema.merge!(default: final_defaults[opt_key.to_s])
        end

        self.option opt_key, opt_schema
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
