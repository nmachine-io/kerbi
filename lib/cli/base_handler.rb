module Kerbi
  module Cli

    ##
    # Superclass for all Thor CLI handlers.
    class BaseHandler < Thor
      include Kerbi::Mixins::CliStateHelpers

      protected

      ##
      # Convenience method for instantiating (and memoizating) a state
      # management backend.
      def state_backend(**opts)
        @_state_backend ||= generate_state_backend(**opts)
      end

      ##
      # Sets two very commonly used variables in the run_opts
      # object, available to all subclasses.
      def mem_dna(release_name, project_uri=nil)
        run_opts.release_name = release_name
        run_opts.project_uri = project_uri
      end

      def perform_templating
        if run_opts.local_engine?
          perform_local_templating
        else
          perform_remote_templating
        end
      end

      def perform_local_templating
        Kerbi::Utils::Cli.run_mixers(
          Kerbi::Globals.mixers,
          compile_values,
          run_opts.release_name
        )
      end

      def perform_remote_templating
        Kerbi::Revision::Fetcher.post_template(
          remote_engine_root_url,
          run_opts.revision_tag
        )
      end

      def remote_engine_root_url
      end

      ##
      # Looks at the CLI options to determine which
      # data serializer should be used.
      # @param [Hash] options
      # @return [Class<Kerbi::Cli::BaseSerializer>|null]
      def resolve_serializer(options={})
        if run_opts.output_json?
          winner = options[:json_serializer]
        elsif run_opts.output_yaml?
          winner = options[:yaml_serializer]
        elsif run_opts.output_table?
          winner = options[:table_serializer]
        else
          raise "Unknown output format '#{run_opts.output_format}'"
        end
        winner || options[:serializer]
      end

      ##
      # Pretty prints data to STDOUT selecting the right
      # serializer, and coercing data if requested by the
      # caller.
      # @param [Hash|Array<Object>] dicts
      def echo_data(items, **opts)
        utils = Kerbi::Utils::Cli
        serializer = resolve_serializer(opts)
        items = utils.coerce_hash_or_array(items, opts)
        if serializer
          if items.is_a?(Array)
            items = items.map{ |e| serializer.new(e).serialize }
          else
            items = serializer.new(items).serialize
          end
        end

        if run_opts.output_yaml?
          printable_str = utils.dicts_to_yaml(items)
        elsif run_opts.output_json?
          printable_str = utils.dicts_to_json(items)
        elsif run_opts.output_table?
          printable_str = utils.list_to_table(items, serializer)
        else
          raise "Unknown output format '#{run_opts.output_format}'"
        end

        echo(printable_str)
      end

      def echo(printable_str)
        $stdout.puts printable_str
      end

      ##
      # Returns single merged dict containing all values given or
      # pointed to by the CLI args, plus the default values.yaml file.
      # This includes values from files, inline expressions, and the
      # state ConfigMap.
      # @return [Hash] symbol-keyed dict of all loaded values
      def compile_values
        @_compiled_values ||=
          begin
            utils = Kerbi::Utils::Values

            fname_exprs = run_opts.fname_exprs
            fname_exprs = ["values", *fname_exprs] if run_opts.load_defaults?
            fname_exprs = fname_exprs.reject{ |f| f.start_with?("r:") }

            file_values = utils.from_files(
              fname_exprs,
              root: run_opts.project_root
            )

            inline_values = utils.from_inlines(run_opts.inline_val_exprs)
            state_values = read_state_values

            file_values.
              deep_merge(state_values).
              deep_merge(inline_values)
          end
      end

      ##
      # Compiles the values from only the default values file,
      # e.g values.yaml, or values/values.yaml.
      # @return [Hash]
      def compile_default_values
        utils = Kerbi::Utils::Values
        if run_opts.load_defaults?
          utils.from_files(['values'], root: run_opts.project_root)
        else
          {}
        end
      end

      ##
      # Called by command-methods that need to start with a set
      # of default options that is not the normal default,
      # i.e that is not Kerbi::Consts::OptionDefaults::BASE.
      # @param [Hash] defaults alternative defaults
      def prep_opts(defaults)
        @_options_obj = Kerbi::RunOpts.new(options, defaults)
      end

      ##
      # Returns a re-usable instance of the CLI-args
      # wrapper Kerbi::RunOpts
      # @return [Kerbi::RunOpts] re-usable instance
      def run_opts
        @_options_obj ||= Kerbi::RunOpts.new(
          options,
          Kerbi::Consts::OptionDefaults::BASE
        )
      end

      ##
      # Convenience class method for declaring a Thor subcommand
      # metadata bundle, in accordance with the schema in
      # Kerbi::Consts::OptionSchemas.
      # @param [Hash] _schema a dict from Kerbi::Consts::OptionSchemas
      # @param [Class<Thor>] handler_cls the handler
      def self.sub_cmd_meta(_schema, handler_cls)
        schema = _schema.deep_dup
        desc(schema[:name], schema[:desc])
        subcommand schema[:name], handler_cls
      end

      def self.option_defaults_hash
        @_option_defaults_hash ||= {}
      end

      # def self.set_default_options_for_next(defaults)
      #   defaults ||= Kerbi::Consts::OptionDefaults::BASE
      #   option_defaults_hash[:__next__] = defaults.deep_dup
      # end

      ##
      # Convenience class method for declaring a Thor command
      # metadata bundle, in accordance with the schema in
      # Kerbi::Consts::OptionSchemas.
      # @param [Hash] _schema a dict from Kerbi::Consts::OptionSchemas
      def self.cmd_meta(_schema)
        schema = _schema.deep_dup
        desc(schema[:name], schema[:desc])
        # set_default_options_for_next(schema[:defaults])
        (schema[:options] || []).each do |opt_schema|
          opt_key = opt_schema.delete(:key)
          self.option opt_key, opt_schema
        end
      end

      def self.exit_on_failure?
        true
      end

      def user_confirmed?(message='Are you sure?')
        unless run_opts.confirmed?
          end_with = "Enter 'yes' to confirm or re-run with --confirm."
          echo("#{message} #{end_with}")
          unless STDIN.gets.strip.downcase == "yes"
            echo("Aborted")
            return false
          end
        end
        true
      end

      private

      def utils
        Kerbi::Utils
      end
    end
  end
end
