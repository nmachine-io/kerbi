module Kerbi
  module Utils
    module Mixing

      ##
      # Parses and interpolates YAML or JSON dicts and outputs
      # their symbol-keyed Hash forms.
      # @param [String] yaml_str plain yaml, json, or erb string
      # @param [Hash] extras additional hash passed to ERB
      # @return [Array<Hash>] list of inflated dicts
      def self.yaml_str_to_dicts(yaml_str, opts={})
        interpolated_yaml = self.interpolate_erb_string(yaml_str, **opts)
        hashes = YAML.load_stream(interpolated_yaml)
        self.clean_and_filter_dicts(hashes, **opts)
      end

      ##
      # Loads a YAML/JSON/ERB file, parses it, interpolates it,
      # and returns the resulting dicts.
      # @param [String] fname simplified or absolute path of file
      # @param [Hash] extras additional hash passed to ERB
      # @return [Array<Hash>] list of res-hashes
      def self.yaml_file_to_dicts(fname, opts={})
        contents = File.read(fname)
        begin
          self.yaml_str_to_dicts(contents, **opts)
        rescue Error => e
          STDERR.puts "Exception below from file #{fname}"
          raise e
        end
      end

      ##
      # Performs ERB interpolation on an ERB string, and returns
      # the interpolated string.
      # @param [String] yaml_str contents of a yaml or yaml.erb
      # @param [Hash] opts an additional hash available to ERB
      # @return [String] the interpolated string
      def self.interpolate_erb_string(yaml_str, opts={})
        final_binding = opts[:src_binding] || binding
        final_binding.local_variable_set(:extras, opts[:extras] || {})
        ERB.new(yaml_str).result(final_binding)
      end

      ##
      # Loads, interpolates, and parses all dicts found in all YAML/JSON/ERB
      # files in a given directory.
      # @param [String] dir relative or absolute path of the directory
      # @param [Array<String>] file_blacklist list of filenames to avoid
      # @return [Array<Hash>] array of processed dicts
      def self.yamls_in_dir_to_dicts(pwd, dir, opts={})
        file_blacklist = opts.delete(:file_blacklist)
        blacklist = file_blacklist || []

        dir ||= pwd
        dir = "#{pwd}/#{dir}" if dir && pwd && dir.start_with?(".")
        yaml_files = Dir["#{dir}/*.yaml"]
        erb_files = Dir["#{dir}/*.yaml.erb"]

        (yaml_files + erb_files).map do |fname|
          is_blacklisted = blacklist.include?(File.basename(fname))
          unless is_blacklisted
            self.yaml_file_to_dicts(fname, **opts)
          end
        end.compact.flatten
      end

      ##
      # Turns hashes into symbol-keyed hashes,
      # and applies white/blacklisting based on filters supplied
      # @param [Array<Hash>] dicts list of inflated hashes
      # @param [Array<String>] white_rules list/single k8s res ID to whitelist
      # @param [Array<String>] black_rules list/single  k8s res ID to blacklist
      # @return [Array<Hash>] list of clean and filtered hashes
      def self.clean_and_filter_dicts(dicts, opts={})
        white_rules = opts[:white_rules] || opts[:only]
        black_rules = opts[:black_rules] || opts[:except]
        _dicts = self.hash_to_cloned_hashes(dicts)
        _dicts = _dicts.compact.map(&:deep_symbolize_keys).to_a
        _dicts = self.select_res_dicts_whitelist(_dicts, white_rules)
        _dicts = self.select_res_dicts_blacklist(_dicts, black_rules)
        self.sanitize_res_dict_list(_dicts)
      end

      def self.sanitize_res_dict_list(res_dicts)
        pushable_list = nil
        if res_dicts.is_a?(Array)
          pushable_list = res_dicts
        elsif res_dicts.is_a?(Hash)
          pushable_list = [res_dicts]
        end

        if pushable_list.present?
          #noinspection RubyNilAnalysis
          pushable_list.select do |item|
            item.present? && item.is_a?(Hash)
          end.map(&:deep_symbolize_keys).compact
        else
          []
        end
      end

      ##
      # @return [Array<Hash>] list of clean and filtered hashes
      def self.hash_to_cloned_hashes(hashes)
        if !hashes.is_a?(Array)
          [hashes]
        else
          hashes
        end
      end

      ##
      # Returns res dicts that match one or more rules
      # @param [Array<Hash>] res_dicts k8s res-hashes
      # @param [Array<String>] rule_dicts list of simple k8s res-ids by which to filter
      # @return [Array<Hash>] list of clean and filtered hashes
      def self.select_res_dicts_whitelist(res_dicts, rule_dicts)
        _res_dicts = res_dicts.compact.map(&:deep_symbolize_keys).to_a
        return _res_dicts if (rule_dicts || []).compact.empty?
        _res_dicts.select do |res_dict|
          rule_dicts.any? do |rule_dict|
            self.res_dict_matches_rule?(res_dict, rule_dict)
          end
        end
      end

      ##
      # Returns res dicts that match zero rules
      # @param [Array<Hash>] res_dicts k8s res-hashes
      # @param [Array<String>] rule_dicts list of simple k8s res-ids by which to filter
      # @return [Array<Hash>] list of clean and filtered hashes
      def self.select_res_dicts_blacklist(res_dicts, rule_dicts)
        _res_dicts = res_dicts.compact.map(&:deep_symbolize_keys).to_a
        return _res_dicts if (rule_dicts || []).compact.empty?
        _res_dicts.reject do |res_dict|
          rule_dicts.any? do |rule_dict|
            self.res_dict_matches_rule?(res_dict, rule_dict)
          end
        end
      end

      ##
      # Checks whether a dict, assumed to be a Kubernetes resource,
      # matches a kerbi resource selection rule.
      # @param [Hash] res_dict the Kubernetes-style resource dict
      # @param [Hash] rule_dict the kerbi resource selector dict
      # @return [TrueClass, FalseClass] true if the selector selects the resource
      def self.res_dict_matches_rule?(res_dict, rule_dict)
        return false unless res_dict.is_a?(Hash)
        return false unless res_dict.present?

        return false unless rule_dict.is_a?(Hash)
        return false unless rule_dict.present?

        target_kind = rule_dict[:kind].presence
        target_name = rule_dict[:name].presence
        if !target_kind || self.str_cmp(target_kind, res_dict[:kind])
          wild = !target_name || target_name == "*"
          res_name = res_dict[:metadata]&.[](:name)
          wild || self.str_cmp(target_name, res_name)
        end
      end

      ##
      # Checks whether the value matching string given in a kerbi
      # resource selector dict matches the value of the attribute
      # in the Kubernetes-style resource dict. Works by performing
      # a regex check on the two values with a full stop e.g ^$.
      # @param [String] rule_str the regex to test the candidate string
      # @param [String] actual_str the candidate string being tested
      # @return [TrueClass, FalseClass] true if the rule matches the input
      def self.str_cmp(rule_str, actual_str)
        final_regex = Regexp.new("^#{rule_str}$")
        match_result = actual_str =~ final_regex
        !match_result.nil?
      end

    end
  end
end