module Kerbi
  module State

    ##
    # Represents a single Kerbi state entry.
    class Entry

      ##
      # Tag prefix that identifies candidate states
      # @return [String]
      CANDIDATE_PREFIX = "[cand]-"

      ##
      # Array of record attribute names in symbol form
      # @return [Array<Symbol>]
      ATTRS = %i[tag revision message values default_values created_at]

      ##
      # Subset of attribute names (symbol form) that
      # the user can mass update (i.e Rails' attr_accessible)
      SETTABLE_ATTRS = %i[message created_at]

      ##
      # Parent collection. Necessary for computation that involve
      # comparision.
      # @return [Array<Kerbi::State::EntrySet>]
      attr_accessor :set

      ##
      # Human readable string that identifies this state
      # @return [String]
      attr_accessor :tag

      ##
      # SemVer of chart/mixer, for user info purposes only
      # @return [String]
      attr_accessor :revision

      ##
      # Message for/by user, for user info purposes only
      # @return [String]
      attr_accessor :message

      ##
      # The default values computed at templating time
      # @return [Hash]
      attr_accessor :default_values

      ##
      # The final values computed at templating time
      # @return [Hash]
      attr_accessor :values

      ##
      # The default values computed at templating time
      # @return [Time]
      attr_accessor :created_at

      ##
      # List of errors, encoded in a simple struct, picked
      # up during a validation run
      # @return [Array<Hash>]
      attr_reader :validation_errors

      def initialize(set, dict)
        @set = set
        ATTRS.each do |attr|
          instance_variable_set("@#{attr}", dict[attr].freeze)
        end
        @_was_validated = false
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
      # Ghetto attribute validation. Pushes a attr => msg hash to the
      # @validation_errors for every problem found. Does not raise on
      # problems.
      # @return [NilClass]
      def validate
        @validation_errors.push(
          attr: 'tag',
          msg: "Cannot be empty",
          value: tag
        ) unless tag.present?

        @_was_validated = true
      end

      def valid?
        raise "valid? called before #validate" unless @_was_validated
        validation_errors.empty?
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

      ##
      # Dynamically assign as a user.
      # @param [String|Symbol] attr_name
      # @param [Object] new_value
      # @return [String] the old value, for convenience
      def assign_attr(attr_name, new_value)
        if SETTABLE_ATTRS.include?(attr_name.to_sym)
          old_value = send(attr_name)
          send("#{attr_name}=", new_value)
          old_value
        else
          raise Kerbi::NoSuchStateAttrName
        end
      end

      ##
      # Replace current tag with a new one, where the new
      # one can contain special interpolatable words like
      # @candidate.
      # @param [String] new_tag_expr
      # @return [String] the old tag, for convenience
      def retag(new_tag_expr)
        old_tag = tag
        self.tag = set.resolve_write_tag_expr(new_tag_expr)
        old_tag
      end

      ##
      # Removes the [cand]- part of the tag, making this
      # entry lose its candidate status.
      #
      # Raises an exception if this entry was not a candidate.
      # @return [String] the old tag, for convenience
      def promote
        raise Kerbi::StateNotPromotable unless candidate?
        old_tag = tag
        self.tag = tag[CANDIDATE_PREFIX.length..]
        old_tag
      end

      ##
      # Adds the [cand]- flag to this entry's tag, making this
      # entry gain candidate status.
      #
      # Raises an exception if this entry was already a candidate.
      # @return [String] the old tag, for convenience
      def demote
        raise Kerbi::StateNotDemotable unless committed?
        old_tag = tag
        self.tag = "#{CANDIDATE_PREFIX}#{tag}"
        old_tag
      end

      ##
      # Convenience method to get all overridden keys between
      # the values and default_values dicts.
      # @return [Array<String>]
      def overridden_keys
        (delta = overrides_delta) ? delta.keys.map(&:to_s) : []
      end

      ##
      # Serializes the instance's recordable attributes to
      # a string-keyed Hash
      # @return Hash
      def to_h
        special_ser = {
          values: values || {},
          default_values: default_values || {},
          created_at: created_at.to_s
        }
        Hash[ATTRS.map{|k|[k, send(k)]}].merge(special_ser)
      end
      alias_method :serialize, :to_h

      ##
      # Serializes the instance's recordable attributes to a
      # JSON string
      # @return [String]
      def to_json
        JSON.dump(serialize)
      end

      ##
      # Deserializes a record in dict-form and returns the
      # corresponding Entry instance.
      # @param [Hash] serialized record
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