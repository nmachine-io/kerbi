module Kerbi
  module State

    ##
    # Baby version of ActiveRecord::Relation. Holds an array of
    # entries (i.e Kerbi::State::Entry) and exposes useful group-level
    # operations, like sorting, find maximums, etc...
    class EntrySet

      include Kerbi::Mixins::EntryTagLogic

      attr_reader :entries
      attr_reader :release_name

      # @param [Array<Hash>] dicts
      def initialize(dicts, **opts)
        @entries = dicts.map { |h| Entry.from_dict(self, h) }
        @release_name = opts[:release_name]
        sort_by_created_at
      end

      def validate!
        entries.each(&:validate)
        if (bad_entries = entries.reject(&:valid?)).any?
          errors = Hash[bad_entries.map do |entry|
            [entry.tag, entry.validation_errors.deep_dup]
          end]
          raise Kerbi::EntryValidationError.new(errors)
        end
      end

      ##
      # Filters entries by candidate status, returning only the
      # ones that are NOT candidates.
      # @return [Array<Kerbi::State::Entry>]
      def committed
        entries.select(&:committed?)
      end

      ##
      # Filters entries by candidate status, returning only the
      # ones that ARE candidates.
      # @return [Array<Kerbi::State::Entry>]
      def candidates
        entries.reject(&:committed?)
      end

      ##
      # Finds the most recently created/updated entry in the list
      # that is not a candidate.
      # @return [?Kerbi::State::Entry]
      def latest
        committed.first
      end

      ##
      # Finds the least recently created/updated entry in the list
      # that is not a candidate.
      # @return [?Kerbi::State::Entry]
      def oldest
        committed.last
      end

      ##
      # Finds the most recently created/updated entry in the list
      # that is a candidate.
      # @return [?Kerbi::State::Entry]
      def latest_candidate
        candidates.first
      end

      ##
      # Given a target entry tag expression, searches underlying array
      # for the corresponding entry.
      #
      # Assumes the tag expression contains special interpolatable words,
      # and thus resolves the tag expression into a literal tag first.
      #
      # Invokes tag resolution logic specific to reading entries, which
      # is different than for writing entries (see #resolve_read_tag_expr).
      # @param [String] tag_expr
      # @return [Kerbi::State::Entry]
      def find_entry_for_read(tag_expr)
        resolved_tag = resolve_read_tag_expr(tag_expr)
        entry = find_by_literal_tag(resolved_tag)
        raise Kerbi::StateNotFoundError.new(tag_expr) unless entry
        entry
      end

      ##
      # Given a target entry tag expression, searches underlying array
      # for the corresponding entry.
      #
      # Assumes the tag expression contains special interpolatable words,
      # and thus resolves the tag expression into a literal tag first.
      #
      # Invokes tag resolution logic specific to writing entries, which
      # is different than for reading entries (see #resolve_write_tag_expr).
      #
      # If an entry is not found, initializes a new empty entry with the
      # given resolved tag, and adds it to the set's underlying array.
      # @param [String] tag_expr
      # @return [?Kerbi::State::Entry]
      def find_or_init_entry_for_write(tag_expr)
        resolved_tag = resolve_write_tag_expr(tag_expr)
        if(existing_entry = find_by_literal_tag(resolved_tag))
          existing_entry
        else
          entry = Kerbi::State::Entry.new(self, tag: resolved_tag)
          entries.unshift(entry)
          entry
        end
      end

      ##
      # Performs simple linear search for an entry whose tags matches
      # exactly tag_expr.
      # @param [String] tag_expr
      # @return [?Kerbi::State::Entry]
      def find_by_literal_tag(tag_expr)
        return nil unless tag_expr.present?
        entries.find { |e| e.tag == tag_expr }
      end
      alias_method :get, :find_by_literal_tag


      def prune_candidates
        entries.select!(&:committed?)
      end

      def sort_by_created_at
        entries.sort! do |a, b|
          both_defined = a.created_at && b.created_at
          both_defined ? b.created_at <=> a.created_at : 0
        end
      end
    end
  end
end