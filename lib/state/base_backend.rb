module Kerbi
  module State
    class BaseBackend
      include Kerbi::Mixins::EntryTagLogic


      def initialize(options={})
      end

      # @return [Kerbi::State::EntrySet]
      def entry_set
        @_entry_set ||= read_entries
      end

      # @return [Array<Kerbi::State::Entry>]
      def entries
        entry_set.entries
      end

      # @return [Kerbi::State::Backend]
      def state_backend(namespace=nil)
        @_state_backend ||= generate_state_backend(namespace)
      end

      # @param [Kerbi::State::Entry] entry
      def delete_entry(entry)
        entries.reject! { |e| e.tag == entry.tag }
        save
        @_entry_set = nil
        @_resource = nil
      end

      def save
        update_resource
        @_entry_set = nil
        @_resource = nil
      end

      protected

      def resource
        @_resource ||= load_resource
      end

      def update_resource
        raise NotImplementedError
      end

      # @return [Kerbi::State::EntrySet]
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
    end
  end
end