module Kerbi
  module State
    class BaseBackend
      include Kerbi::Mixins::StateEntryCreation


      def initialize(options={})
      end

      # @return [Array<Kerbi::State::Entry>]
      def entries
        @_entries ||= read_entries
      end

      # @return [Kerbi::State::Backend]
      def state_backend(namespace=nil)
        @_state_backend ||= generate_state_backend(namespace)
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
        end
      end

      # @param [Kerbi::State::Entry] entry
      def update_entry(entry, attrs)
        entry.tag = attrs[:tag] if attrs[:tag].present?
        entry.values = attrs[:values] unless attrs[:values].nil?
        entry.created_at = Time.now
        save
      end

      # @param [Kerbi::State::Entry] entry
      def delete_entry(entry)
        entries.reject! { |e| e.tag == entry.tag }
        save
        @_entries = nil
        @_resource = nil
      end

      def save
        update_resource
        @_entries = nil
        @_resource = nil
      end

      protected

      def resource
        @_resource ||= load_resource
      end

      def update_resource
        raise NotImplementedError
      end

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