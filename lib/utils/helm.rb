module Kerbi
  module Utils
    module Helm

      def self.config
        Kerbi::ConfigFile::Manager
      end

      ##
      # Tests whether Kerbi can invoke Helm commands
      # @return [Boolean] true if helm commands succeed locally
      def self.can_exec?
        !!system(config.helm_exec, out: File::NULL, err: File::NULL)
      end

      ##
      # Writes a hash of values to a YAML to a temp file
      # @param [Hash] values a hash of values
      # @return [String] the path of the file
      def self.make_tmp_values_file(values)
        File.open(config.tmp_helm_values_path, 'w') do |f|
          f.write(YAML.dump((values || {}).deep_stringify_keys))
        end
        config.tmp_helm_values_path
      end

      ##
      # Deletes the temp file
      # @return [void]
      def self.del_tmp_values_file
        if File.exists?(config.tmp_helm_values_path)
          File.delete(config.tmp_helm_values_path)
        end
      end

      ##
      # Joins assignments in flat hash into list of --set flags
      # @param [Hash] inline_assigns flat Hash of deep_key: val
      # @return [String] corresponding space-separated --set flags
      def self.encode_inline_assigns(inline_assigns)
        (inline_assigns || []).map do |key, value|
          raise "Assignments must be flat"  if value.is_a?(Hash)
          "--set #{key}=#{value}"
        end.join(" ")
      end

      ##
      # Runs the helm template command
      # @param [String] release release name to pass to Helm
      # @param [String] project <org>/<chart> string identifying helm chart
      # @return [Array<Hash>]
      def self.template(release, project, opts={})
        raise "Helm executable not working" unless can_exec?
        tmp_file = make_tmp_values_file(opts[:values])
        inline_flags = encode_inline_assigns(opts[:inline_assigns])
        command = "#{config.helm_exec} template #{release} #{project}"
        command += " -f #{tmp_file} #{inline_flags} #{opts[:cli_args]}"
        output = `#{command}`
        del_tmp_values_file
        YAML.load_stream(output)
      end
    end
  end
end