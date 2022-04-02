module Kerbi
  module State
    class BaseBackend
      def initialize(options={})

      end

      def load_source
      end

      def read_entries
        raise NotImplementedError
      end

      # @param [String] tag
      # @return [Kerbi::State::Entry]
      def find_entry(tag)
        read_entries.find { |entry| entry.tag == tag }
      end

      private

      def utils
        Kerbi::Utils
      end

      # @param [Array<Kerbi::State::Entry>] entries
      # @return [Array<Kerbi::State::Entry>]
      def self.post_process_entries(entries)
        sort_by_created_at(entries)
        entries[0]&.is_latest = true
        entries
      end

      # @param [Array<Kerbi::State::Entry>] entries
      def self.sort_by_created_at(entries)
        entries.sort! do |a, b|
          both_defined = a.created_at && b.created_at
          both_defined ? b.created_at <=> a.created_at : 0
        end
      end
    end
  end
end