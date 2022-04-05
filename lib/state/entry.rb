module Kerbi
  module State

    ##
    # Represents a single Kerbi state entry.
    class Entry

      CANDIDATE_PREFIX = "[cand]-"

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

      ## A state entry is a 'candidate' if its tag has the
      # candidate signature - that is it starts with [cand]-.
      # @return [TrueClass, FalseClass]
      def candidate?
        tag.start_with?(CANDIDATE_PREFIX)
      end

      ##
      # Convenience method that returns the negation of #candidate?
      # @return [TrueClass, FalseClass]
      def committed?
        !candidate?
      end

      ##
      # Queries the collection from which this entry comes to determine
      # whether or not this entry has the newest 'created_at'.
      #
      # Note that whether this entry is a candidate or not affects the result.
      # If it is a candidate, it will only compare itself to other candidates.
      # If it is not, it will only compare itself to non-candidates.
      # @return [TrueClass, FalseClass]
      def latest?
        return set&.latest&.tag == tag if committed?
        set&.latest_candidate&.tag == tag if candidate?
      end

      ##
      # Computes a delta between this state's values and its
      # default values.
      # @return [Hash]
      def overrides_delta
        if values.is_a?(Hash) & default_values.is_a?(Hash)
          Kerbi::Utils::Misc.deep_hash_diff(default_values, values)
        else
          nil
        end
      end

      def assign_attr(attr_name, new_value)
        setter_name = "#{attr_name}="
        if self.respond_to?(setter_name)
          send(setter_name, new_value)
        else

        end
      end

      # @param [String] new_tag_expr
      def retag(new_tag_expr)
        old_tag = tag
        self.tag = set.resolve_write_tag_expr(new_tag_expr)
        old_tag
      end

      def promote
        raise Kerbi::StateNotPromotable unless candidate?
        old_tag = tag
        self.tag = tag[CANDIDATE_PREFIX.length..]
        old_tag
      end

      def demote
        raise Kerbi::StateNotDemotable unless committed?
        old_tag = tag
        self.tag = "#{CANDIDATE_PREFIX}#{tag}"
        old_tag
      end

      # @return [Array<String>]
      def overridden_keys
        (delta = overrides_delta) ? delta.keys.map(&:to_s) : []
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