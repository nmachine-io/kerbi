module Kerbi
  module State
    class Entry
      attr_reader :tag
      attr_reader :message
      attr_reader :values
      attr_reader :created_at

      def initialize(dict)
        %i[tag message values created_at].each do |attr|
          instance_variable_set("@#{attr}", dict[attr].freeze)
        end
      end

      def candidate?
        tag == 'candidate'
      end

      # @param [Hash] dict
      # @return [Kerbi::State::Entry]
      def self.from_dict(dict={})
        dict.deep_symbolize_keys!
        created_at = DateTime.new(dict.delete(:created_at)) rescue nil
        self.new(
          **dict,
          created_at: created_at
        )
      end

      def serialize
        {
          tag: tag,
          message: message,
          values: values || {},
          created_at: created_at.to_s
        }
      end

      def to_json
        JSON.dump(serialize)
      end
    end
  end
end