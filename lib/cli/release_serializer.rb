module Kerbi
  module Cli
    class ReleaseSerializer < Kerbi::Cli::BaseSerializer
      has_attributes(
        :name,
        :backend,
        :namespace,
        :resource,
        :states,
        :latest
      )

      def name
        object.release_name
      end

      def backend
        "later"
      end

      def resource
        object.resource_name
      end

      def states
        object.entries.count
      end

      def latest
        object.entry_set.latest&.tag
      end

    end
  end
end