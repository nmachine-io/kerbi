module Kerbi
  module Mixins
    module StatePrinting

      # @return [Class<Kerbi::Cli::EntryRowSerializer>]
      def serializer_cls
        Kerbi::Cli::EntryRowSerializer
      end
    end
  end
end