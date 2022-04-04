module Kerbi
  module State
    class BaseBackend

      def initialize(options={})

      end

      def resource
        @_resource ||= load_resource
      end

      def entries
        @_entries ||= read_entries
      end

      # @param [String] expr target entry id or tag
      # @return [Kerbi::State::Entry]
      def find_entry(expr)
        if Entry.latest_expr?(expr)
          backend.entries.find(&:latest?)
        elsif Entry.candidate_expr?(expr)
          backend.entries.find(&:candidate?)
        elsif Entry.tag_expr?(expr)
          entries.find { |entry| entry.tag == expr }
        elsif Entry.id_expr?(expr)
          entries.find { |entry| entry.id == expr }
        end
      end

      def delete_entry(entry)
        new_entries = entries.reject { |e| e.id == entry.id }

      end

      protected

      def read_entries
        raise NotImplementedError
      end

      def load_resource
        raise NotImplementedError
      end

      private

      def utils
        Kerbi::Utils
      end

      # @param [Array<Kerbi::State::Entry>] entries
      # @return [Array<Kerbi::State::Entry>]
      def self.post_process_entries(entries)
        sort_by_created_at(entries)
        entries.each do |entry|
          unless entry.candidate?
            entries.is_latest = true
            break
          end
        end
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