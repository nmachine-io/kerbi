module Kerbi
  module State
    class EntrySet

      include Kerbi::Mixins::EntryTagLogic

      attr_reader :entries

      # @param [Array<Hash>] dicts
      def initialize(dicts)
        @entries = dicts.map { |h| Entry.from_dict(self, h) }
        sort_by_created_at
      end

      # @return [Array<Kerbi::State::Entry>]
      def committed
        entries.select(&:committed?)
      end

      # @return [Array<Kerbi::State::Entry>]
      def candidates
        entries.reject(&:committed?)
      end

      # @return [?Kerbi::State::Entry]
      def latest
        committed.first
      end

      # @return [?Kerbi::State::Entry]
      def latest_candidate
        candidates.first
      end

      # @return [?Kerbi::State::Entry]
      def latest_versioned
        committed.find(&:versioned?)
      end

      # @return [String]
      def latest_version
        latest_versioned&.tag
      end

      # @param [String] tag_expr
      # @return [Kerbi::State::Entry]
      def find_entry_for_read(tag_expr)
        resolved_tag = resolve_read_tag_expr(tag_expr)
        entry = find_by_literal_tag(resolved_tag)
        raise Kerbi::StateNotFoundError unless entry
        entry
      end

      ## Has side effect!
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

      # @param [String] tag_expr
      # @return [?Kerbi::State::Entry]
      def find_by_literal_tag(tag_expr)
        return nil unless tag_expr.present?
        entries.find { |e| e.tag == tag_expr }
      end

      def raise_if_illegal_tag_expr(tag_expr)
        illegal = self.class.illegal_write_tag_expr?(tag_expr)
        raise Kerbi::IllegalWriteStateTagWordError if illegal
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