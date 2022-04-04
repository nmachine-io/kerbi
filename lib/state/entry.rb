module Kerbi
  module State
    class Entry

      CANDIDATE_PREFIX = "c/"

      ATTRS = %i[tag message values default_values created_at]

      attr_accessor :set

      attr_accessor :tag
      attr_accessor :message
      attr_accessor :default_values
      attr_accessor :values
      attr_accessor :created_at

      attr_reader :validation_errors

      def initialize(set, dict)
        @set = set
        ATTRS.each do |attr|
          instance_variable_set("@#{attr}", dict[attr].freeze)
        end
        @is_latest = false
        @validation_errors = []
      end

      # @return [TrueClass, FalseClass]
      def candidate?
        tag.start_with?(CANDIDATE_PREFIX)
      end

      # @return [TrueClass, FalseClass]
      def committed?
        !candidate?
      end

      # @return [TrueClass, FalseClass]
      def latest?
        return set&.latest&.tag == tag if committed?
        set&.latest_candidate&.tag == tag if candidate?
      end

      def default_new_delta
        if values.is_a?(Hash) & default_values.is_a?(Hash)
          Kerbi::Utils::Misc.deep_hash_diff(default_values, values)
        else
          nil
        end
      end

      def to_h
        special_ser = {
          values: values || {},
          default_values: default_values || {},
          created_at: created_at.to_s
        }
        Hash[ATTRS.map{|k|[k, send(k)]}].merge(special_ser)
      end
      alias_method :serialize, :to_h

      def to_json
        JSON.dump(serialize)
      end

      # @param [Hash] dict
      # @return [Kerbi::State::Entry]
      def self.from_dict(set, dict={})
        dict.deep_symbolize_keys!
        dict.slice!(*ATTRS)

        self.new(
          set,
          **dict,
          values: dict[:values] || {},
          default_values: dict[:default_values] || {},
          created_at: (Time.parse(dict[:created_at]) rescue nil)
        )
      end

      def self.versioned?(expr)
        Gem::Version.correct?(expr)
      end
    end
  end
end