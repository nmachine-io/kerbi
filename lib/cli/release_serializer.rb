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
        object.class.type_signature
      end

      def resource
        object.resource_name
      end

      def states
        if object.working?
          object.entries.count
        else
          broken_txt
        end
      end

      def latest
        if object.working?
          object.entry_set.latest&.tag
        else
          broken_txt
        end
      end

      def broken_txt
        "ERR"
      end
    end
  end
end