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

      ##
      # Credit: https://gist.github.com/henrik/146844
      # @param [Hash] hash_a
      # @param [Hash] hash_b
      def self.deep_hash_diff(hash_a, hash_b)
        (hash_a.keys | hash_b.keys).inject({}) do |diff, k|
          if hash_a[k] != hash_b[k]
            if hash_a[k].is_a?(Hash) && hash_b[k].is_a?(Hash)
              diff[k] = deep_hash_diff(hash_a[k], hash_b[k])
            else
              diff[k] = [hash_a[k], hash_b[k]]
            end
          end
          diff
        end
      end

      ##
      # Credit: https://stackoverflow.com/a/195894/11913562
      # @param [Time] other
      # @return [String]
      def self.pretty_time_elapsed(other)
        a = (Time.now - other).to_i
        case a
        when 0 then 'just now'
        when 1 then 'a second ago'
        when 2..59 then a.to_s+' seconds ago'
        when 60..119 then 'a minute ago' #120 = 2 minutes
        when 120..3540 then (a/60).to_i.to_s+' minutes ago'
        when 3541..7100 then 'an hour ago' # 3600 = 1 hour
        when 7101..82800 then ((a+99)/3600).to_i.to_s+' hours ago'
        else other.to_s
        end
      end
    end
  end
end