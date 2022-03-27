module Kerbi
  module Utils

    ##
    # Utilities module for all value loading functionality.
    module Values
      def self.from_files(fname_exprs, **opts)
        final_paths = resolve_fname_exprs(fname_exprs, **opts)
        load_yaml_files(final_paths)
      end

      ##
      # Resolves each filename expression given, returning an array
      # of absolute paths. Automatically prepends the default values filename
      # - values.yaml - to the list and does not complain if it does not exist.
      # If two or more filename expressions resolve to the same absolute path,
      # only one copy will be in the list.
      # @param [Array<String>] fname_exprs cli-level values file path names
      # @param [Hash] opts downstream options for file-loading methods
      # @return [Array<String>] list of unique absolute filenames
      def self.resolve_fname_exprs(fname_exprs, **opts)
        final_exprs = ['values', *fname_exprs].uniq
        final_exprs.map do |fname_expr|
          path = resolve_fname_expr(fname_expr, **opts)
          if fname_expr != 'values' && !path
            raise "Could not resolve file '#{fname_expr}'"
          end
          path
        end.compact.uniq
      end

      ##
      # Loads the dicts from files pointed to by final_file_paths into
      # memory, and returns the deep-merged hash in the order of the files.
      # @param [Array<String>] final_file_paths absolute filenames
      # of value assignment files
      def self.load_yaml_files(final_file_paths)
        final_file_paths.inject({}) do |whole, fname|
          file_values = self.load_yaml_file(fname)
          whole.deep_merge(file_values)
        end
      end

      ##
      # Parses and merges cli-level key-value assignments of the form
      # foo.bar=baz.
      # @param [Array<String>] inline_exprs e.g %w[foo=bar, foo.bar=baz]
      def self.from_inlines(inline_exprs)
        inline_exprs.inject({}) do |whole, str_assignment|
          assignment = self.parse_inline_assignment(str_assignment)
          whole.deep_merge(assignment)
        end
      end

      ##
      # Turns a user supplied values filename into a final, usable
      # absolute filesystem path. This method calls the values_paths method,
      # which assumes a kerbi directory structure.
      # @param [String] expr
      # @param [Hash] opts
      # @return [?String] the absolute filename or nil if it does not exist
      def self.resolve_fname_expr(expr, **opts)
        candidate_paths = self.values_paths(expr, **opts)
        candidate_paths.find do |candidate_path|
          File.exists?(candidate_path)
        end
      end

      ##
      # Parses a single cli-level key-value assignment with the form
      # foo.bar=baz. Raises an exception if the expression is malformed.
      # @param [String] str_assign e.g foo=bar
      # @return [Hash] corresponding symbol hash e.g {foo: bar}
      def self.parse_inline_assignment(str_assign)
        deep_key, value = str_assign.split("=")
        raise "malformed assignment #{str_assign}" unless deep_key && value
        assign_parts = deep_key.split(".") << value
        assignment = assign_parts.reverse.inject{ |a, n| { n => a } }
        assignment.deep_symbolize_keys
      end

      ##
      # Loads and performs all interpolation operations on file, returns
      # corresponding symbol hash of values. File is expected to contain
      # one root element.
      # @param [String] good_fname path of values file
      #noinspection RubyResolve
      # @return [Hash] corresponding value hash
      def self.load_yaml_file(good_fname)
        file_contents = File.read(good_fname)
        interpolated = ErbWrapper.new.interpolate(file_contents)
        YAML.load(interpolated).deep_symbolize_keys
      end

      #noinspection RubyLiteralArrayInspection
      ##
      # Returns all possible paths that a values filename might
      # resolve to according to kerbi conventions. Does not check
      # for file existence. The paths are ordered by similarity to
      # the input expression, starting obviously with the input itself.
      # @param [Object] fname cli-level filename expression for a values file
      # @param [String] root optionally pass in project/mixer root dir
      # @return [Array<String>] all possible paths
      def self.values_paths(fname, root: nil)
        if root.nil?
          root = ''
        else
          root = "#{root}/" unless root.end_with?("/")
        end
        [
          "#{root}#{fname}",
          "#{root}#{fname}.yaml",
          "#{root}#{fname}.json",
          "#{root}#{fname}.yaml.erb",
          "#{root}/values/#{fname}",
          "#{root}/values/#{fname}.yaml.erb",
          "#{root}/values/#{fname}.yaml",
          "#{root}/values/#{fname}.json"
        ]
      end

      class ErbWrapper
        include Kerbi::Mixins::Mixer
        def interpolate(file_cont)
          ERB.new(file_cont).result(binding)
        end
      end
    end
  end
end
