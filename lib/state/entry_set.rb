module Kerbi
  module State
    class EntrySet

      include Kerbi::Mixins::EntryTagLogic

      attr_reader :entries

      # @param [Array<Hash>] dicts
      def initialize(dicts)
        @entries = dicts.map { |h| Entry.from_dict(self, h) }
        post_process_entries
      end

      # @return [Array<Kerbi::State::Entry>]
      def committed
        entries.select(&:committed)
      end

      # @return [Array<Kerbi::State::Entry>]
      def candidates
        entries.reject(&:committed)
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

      def add_or_update(tag_expr, options)
        raise_if_illegal_tag_expr(tag_expr)
      end

      # @param [String] tag_expr
      # @return [?Kerbi::State::Entry]
      def find_entry_for_read(tag_expr, opts={})
        resolved_tag = resolve_read_tag(tag_expr)
        if(result = find_by_literal_tag(resolved_tag))
          result
        elsif exactly_latest?(tag_expr) && opts[:latest_miss] == 'raise'
          raise Kerbi::StateNotFoundError
        elsif exactly_candidate?(tag_expr) && opts[:candidate_miss] == 'raise'
          raise Kerbi::StateNotFoundError
        end
        nil
      end

      ## Has side effect!
      # @param [String] tag_expr
      # @return [?Kerbi::State::Entry]
      def find_or_init_entry_for_write(tag_expr)
        resolved_tag = resolve_write_tag(tag_expr)
        if(existing_entry = find_by_literal_tag(resolved_tag))
          existing_entry
        elsif exactly_candidate?(tag_expr)
          new_tag = resolve_candidate_write_word
          entry = Kerbi::State::Entry.new(self, tag: new_tag)
          entries.unshift(entry)
          entry
        else
          raise Kerbi::StateNotFoundError
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

      def post_process_entries
        sort_by_created_at
        entries.each do |entry|
          unless entry.candidate?
            entries.is_latest = true
            break
          end
        end
        entries
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