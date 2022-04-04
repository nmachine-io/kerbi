module Kerbi
  module State
    class Entry

      CANDIDATE_KW = "candidate"
      LATEST_KW = "latest"

      ATTRS = %i[id tag message values default_values created_at]

      attr_reader :id
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

      # @return [TrueClass, FalseClass]
      def candidate?
        id == CANDIDATE_KW
      end

      # @return [TrueClass, FalseClass]
      def latest?
        !!(!candidate? && is_latest)
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

      def self.new_candidate(options={})
        dict = options.merge(id: CANDIDATE_KW)
      end

      def self.tag_expr?(expr)
        Gem::Version.correct?(expr)
      end

      def self.latest_expr?(expr)
        expr == LATEST_KW
      end

      def self.id_expr?(expr)
        return false unless expr.is_a?(String)
        !tag_expr?(expr)
      end

      def self.candidate_expr?(expr)
        expr == CANDIDATE_KW
      end
    end
  end
end