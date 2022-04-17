module Kerbi
  module State
    class BaseBackend

      attr_reader :release_name
      attr_reader :is_working

      def initialize(options={})
      end

      # @return [Kerbi::State::EntrySet]
      def entry_set
        @_entry_set ||= EntrySet.new(
          read_entries,
          release_name: release_name
        )
      end

      # @return [Array<Kerbi::State::Entry>]
      def entries
        entry_set.entries
      end

      # @param [Kerbi::State::Entry] entry
      def delete_entry(entry)
        entries.reject! { |e| e.tag == entry.tag }
        save
        @_entry_set = nil
        @_resource = nil
      end

      def save
        entry_set.validate!
        update_resource
        @_entry_set = nil
        @_resource = nil
      end

      def delete
        delete_resource
      end

      def resource_signature
        raise NotImplementedError
      end

      def prime
        begin
          resource
          entries
          @is_working = true
        rescue
          @is_working = false
        end
      end

      # @return [TrueClass|FalseClass]
      def working?
        prime if @is_working.nil?
        @is_working
      end

      def self.type_signature
        raise NotImplementedError
      end

      protected

      def resource
        @_resource ||= load_resource
      end

      def update_resource
        raise NotImplementedError
      end

      # @return [Array<Hash>]
      def read_entries
        raise NotImplementedError
      end

      def load_resource
        raise NotImplementedError
      end

      def delete_resource
        raise NotImplementedError
      end

      private

      def utils
        Kerbi::Utils
      end
    end
  end
end