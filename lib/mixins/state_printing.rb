module Kerbi
  module Mixins
    module StatePrinting

      # @return [Class<Kerbi::Cli::EntrySerializer>]
      def serializer_cls
        Kerbi::Cli::EntrySerializer
      end
    end
  end
end