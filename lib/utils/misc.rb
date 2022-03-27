module Kerbi
  module Utils
    module Misc
      def self.one_to_array(item)
        return [] if item.nil?
        if item.is_a?(Array)
          item
        else
          [item]
        end
      end

      ## Given a list of filenames, returns the subset that
      # are real files.
      # @param [Array] candidates filenames to try
      # @return [Array] subset of candidate filenames that are real filenames
      def self.real_files_for(*candidates)
        candidates.select do |fname|
          File.exists?(fname)
        end
      end

      ##
      # Turns a nested dict into a deep-keyed dict. For example
      # {x: {y: 'z'}} becomes {'x.y': 'z'}
      # @param [Hash] hash input nested dict
      # @return [Hash] flattened dict
      def self.flatten_hash(hash)
        hash.each_with_object({}) do |(k, v), h|
          if v.is_a? Hash
            flatten_hash(v).map do |h_k, h_v|
              h["#{k}.#{h_k}".to_sym] = h_v
            end
          else
            h[k] = v
          end
        end
      end
    end
  end
end