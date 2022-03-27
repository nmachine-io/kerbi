module Kerbi
  module Mixins
    module Mixer

      # @param [Hash] dict hash or array
      # @return [String] encoded string
      def embed(dict, indentation)
        _dict = dict.is_a?(Array) ? dict.first : dict
        raw = YAML.dump(_dict).sub("---", "")
        indented_lines = raw.split("\n").map do |line|
          line.indent(indentation)
        end
        "\n#{indented_lines.join("\n")}"
      end

      # @param [Array|Hash] dicts hash or array
      # @return [String] encoded string
      def embed_array(dicts, indentation)
        dicts = [] if dicts.nil?
        unless dicts.is_a?(Array)
          raise "embed_array called with non-array #{dicts.class} #{dicts}"
        end
        raw = YAML.dump(dicts).sub("---", "")
        indented_lines = raw.split("\n").map do |line|
          line.indent(indentation)
        end
        "\n#{indented_lines.join("\n")}"
      end

      # @param [String] string string to be base64 encoded
      # @return [String] encoded string
      def b64enc(string)
        if string
          Base64.strict_encode64(string)
        else
          ''
        end
      end

      # @param [String] string string to be base64 encoded
      # @return [String] encoded string
      def b64dec(string)
        if string
          Base64.decode64(string).strip
        else
          ''
        end
      end

      # @param [String] fname absolute path of file to be encoded
      # @return [String] encoded string
      def b64enc_file(fname)
        file_contents = File.read(fname) rescue nil
        b64enc(file_contents)
      end

      ##
      # @param [Hash] opts options
      # @option opts [String] url full URL to raw yaml file contents on the web
      # @option opts [String] from one of [github]
      # @option opts [String] except list of filenames to avoid
      # @raise [Exception] if project-id/file missing in github hash
      def http_descriptor_to_url(**opts)
        return opts[:url] if opts[:url]

        if opts[:from] == 'github'
          base = "https://raw.githubusercontent.com"
          branch = opts[:branch] || 'master'
          project, file = (opts[:project] || opts[:id]), opts[:file]
          raise "Project and/or file not found" unless project && file
          "#{base}/#{project}/#{branch}/#{file}"
        end
      end
    end
  end
end