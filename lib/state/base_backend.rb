module Kerbi
  module State
    class BaseBackend
      def initialize(options={})

      end

      def load_source
      end

      private

      def utils
        Kerbi::Utils
      end

      # @param [Array<Kerbi::State::Entry>] entries
      # @return [Array<Kerbi::State::Entry>]
      def self.post_process_entries(entries)
        sort_by_created_at(entries)
        entries.first.is_latest = true if entries.any?
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