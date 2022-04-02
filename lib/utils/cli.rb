module Kerbi
  module Utils
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
          table.to_s
        else
          table = Terminal::Table.new do |t|
            entries.each do |key, value|
              _value = value.is_a?(Hash) ? JSON.pretty_generate(value) : value
              t.add_row [key.upcase.to_s.bold, _value]
            end
            t.style = {all_separators: true}
          end
          table.to_s
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
      def self.load_kerbifile(fname_expr)
        fname_expr ||= Dir.pwd
        abs_path = "#{fname_expr}/kerbifile.rb"
        if File.exists?(abs_path)
          #noinspection RubyResolve
          load(abs_path)
        end
      end
    end
  end
end