module Kerbi
  module State
    class Entry

      ATTRS = %i[tag message values default_values created_at]

      attr_reader :tag
      attr_reader :message
      attr_reader :default_values
      attr_reader :values
      attr_reader :created_at
      attr_accessor :is_latest

      def initialize(dict)
        ATTRS.each do |attr|
          instance_variable_set("@#{attr}", dict[attr].freeze)
        end
      end

      def latest?
        !candidate? && is_latest
      end

      def default_new_delta
        if values.is_a?(Hash) & default_values.is_a?(Hash)
          Kerbi::Utils::Misc.deep_hash_diff(default_values, values)
        else
          nil
        end
      end

      def candidate?
        tag.start_with? 'candidate'
      end

      # @param [Hash] dict
      # @return [Kerbi::State::Entry]
      def self.from_dict(dict={})
        dict.deep_symbolize_keys!
        dict.slice!(*ATTRS)

        self.new(
          **dict,
          values: dict[:values] || {},
          default_values: dict[:default_values] || {},
          created_at: (Time.parse(dict[:created_at]) rescue nil)
        )
      end

      def serialize
        {
          tag: tag,
          message: message,
          values: values || {},
          default_values: default_values || {},
          created_at: created_at.to_s
        }
      end

      def to_json
        JSON.dump(serialize)
      end
    end
  end
end