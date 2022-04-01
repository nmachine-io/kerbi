module Kerbi
  module Cli
    class EntrySerializer < Kerbi::Cli::BaseSerializer

      has_attributes(
        :tag,
        :values_defined,
        :changes,
        :created_at,
      )

      def tag
        if object.latest?
          "#{object.tag} [latest]"
        else
          object.tag
        end
      end

      def changes
        3
      end

      def values_defined
        3
      end
    end
  end
end