module Kerbi
  module Utils

    ##
    # Mechanical work for all things CLI that does not deserve
    # to be in the CLI helper mixin.
    module Cli
      ##
      # Convenience method for running and compiling the output
      # of several mixers. Returns all result dicts in a flat array
      # preserving the order they were created in.
      # @param [Array<Class<Kerbi::Mixer>] mixer_classes mixers to run
      # @param [Hash] values root values hash to pass to all mixers
      # @param [Object] release_name helm-like release_name for mixers
      # @return [List<Hash>] all dicts emitted by mixers
      def self.run_mixers(mixer_classes, values, release_name)
        mixer_classes.inject([]) do |whole, gen_class|
          mixer_instance = gen_class.new(values, release_name: release_name)
          whole + mixer_instance.run.flatten
        end
      end

      def self.coerce_hash_or_array(actual, **options)
        if (type = options[:coerce_type]).present?
          if type == 'Array'
            actual.is_a?(Array) ? actual : [actual]
          elsif type == 'Hash'
            actual.is_a?(Array) ? actual[0].to_h : actual.to_h
          else
            raise "Unrecognized type coercion #{type}"
          end
        else
          actual
        end
      end

      ##
      # Turns list of key-symbol dicts into their
      # pretty YAML representation.
      # @param [Array<Hash>|Hash] dicts dicts to YAMLify
      # @return [String] pretty YAML representation of input
      def self.dicts_to_yaml(dicts)
        if dicts.is_a?(Array)
          dicts.each_with_index.map do |h, i|
            raw = YAML.dump(h.deep_stringify_keys)
            raw.gsub("---\n", i.zero? ? '' : "---\n\n")
          end.join("\n")
        else
          return "{}" if dicts.empty?
          as_yaml = YAML.dump(dicts.deep_stringify_keys)
          as_yaml.gsub("---\n", "")
        end
      end

      # @param [Array<Object>] entries
      def self.list_to_table(entries, serializer_cls)
        if entries.is_a?(Array)
          table = Terminal::Table.new(
            headings: serializer_cls.header_titles,
            rows: entries.map(&:values)
          )
          table.style = LIST_TABLE_STYLE
          table.to_s
        else
          table = Terminal::Table.new do |t|
            #noinspection RubyResolve
            entries.each do |key, value|
              new_key = key.upcase.to_s.bold
              new_value = fmt_table_value(value)
              t.add_row [new_key, new_value]
            end
            t.style = DESCRIBE_TABLE_STYLE

          end
          table.to_s
        end
      end

      def self.fmt_table_value(value)
        if value.is_a?(Hash)
          flattened = Kerbi::Utils::Misc.flatten_hash(value)
          stringified = flattened.deep_stringify_keys
          dicts_to_yaml(stringified)
        elsif value.is_a?(Array)
          value.join(",")
        else
          value.to_s
        end
      end

      ##
      # Turns list of key-symbol dicts into their
      # pretty JSON representation.
      # @param [Array<Hash>|Hash] dicts dicts to YAMLify
      # @return [String] pretty JSON representation of input
      def self.dicts_to_json(dicts)
        JSON.pretty_generate(dicts)
      end

      ##
      # Searches the expected paths for the kerbifile and ruby-loads it.
      # @param [String] root directory to search
      def self.load_kerbifile(root_dir)
        root_dir ||= Dir.pwd
        abs_path = "#{root_dir}/kerbifile.rb"
        exists = File.exists?(abs_path)
        raise Kerbi::KerbifileNotFoundError.new(root: root_dir) unless exists
        #noinspection RubyResolve
        load(abs_path)
      end

      ##
      # Given the various Kubernetes authentication options and
      # configs, generates a Hash with the necessary data/schema
      # to pass onto the internal k8s authentication logic.
      #
      # This method only delegates. Actual work done is done here at:
      # Kerbi::Utils::K8sAuth.
      # @return [Hash] auth bundle for the k8s authentication logic.
      # @param [Kerbi::RunOpts] run_opts
      def self.make_k8s_auth_bundle(run_opts)
        case run_opts.k8s_auth_type
        when "kube-config"
          Kerbi::Utils::K8sAuth.kube_config_bundle(
            path: run_opts.kube_config_path,
            name: run_opts.kube_context_name
          )
        when "basic"
          Kerbi::Utils::K8sAuth.basic_auth_bundle(
            username: run_opts.k8s_auth_username,
            password: run_opts.k8s_auth_password
          )
        when "token"
          Kerbi::Utils::K8sAuth.token_auth_bundle(
            bearer_token: run_opts.k8s_auth_token,
            )
        when "in-cluster"
          Kerbi::Utils::K8sAuth.in_cluster_auth_bundle
        else
          raise "Bad k8s connect type '#{run_opts.k8s_auth_type}'"
        end
      end

      def resolve_remote_engine_url
        ""
      end

      LIST_TABLE_STYLE = {
        border_left: false,
        border_right: false,
        border_top: false,
        border_x: "",
        border_y: "",
        border_i: ""
      }.freeze

      DESCRIBE_TABLE_STYLE = {
        all_separators: true,
        border_x: "-",
        border_y: "",
        border_i: ""
      }.freeze

    end
  end
end