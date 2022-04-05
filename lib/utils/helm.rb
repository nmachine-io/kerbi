module Kerbi
  module Utils
    module Helm

      HELM_EXEC = "helm"
      TMP_VALUES_PATH = "/tmp/kerbi-helm-tmp.yaml"
      
      ##
      # Tests whether Kerbi can invoke Helm commands
      # @return [Boolean] true if helm commands succeed locally
      def self.can_exec?
        !!system(HELM_EXEC, out: File::NULL, err: File::NULL)
      end

      ##
      # Writes a hash of values to a YAML to a temp file
      # @param [Hash] values a hash of values
      # @return [String] the path of the file
      def self.make_tmp_values_file(values)
        content = YAML.dump((values || {}).deep_stringify_keys)
        File.write(TMP_VALUES_PATH, content)
        TMP_VALUES_PATH
      end

      ##
      # Deletes the temp file
      # @return [void]
      def self.del_tmp_values_file
        if File.exists?(TMP_VALUES_PATH)
          File.delete(TMP_VALUES_PATH)
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
        command = "#{HELM_EXEC} template #{release} #{project}"
        command += " -f #{tmp_file} #{inline_flags} #{opts[:cli_args]}"
        output = `#{command}`
        del_tmp_values_file
        YAML.load_stream(output)
      end
    end
  end
end