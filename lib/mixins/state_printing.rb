module Kerbi
  module Mixins
    module StatePrinting

      # @param [Kube::State::Entry] entry
      def print_describe(entry)
        data = serializer_cls.new(entry).serialize

      end

      # @param [Array<Kube::State::Entry>] entries
      def print_state_list(entries)
        if cli_opts.output_format("table") == 'table'
          print_state_table(entries)
        else
          print_dicts(entries.map(&:serialize))
        end
      end

      # @param [Array<Kube::State::Entry>] entries
      def print_state_table(entries)
        new_entries = serialize_for_user(entries, serializer_cls)
        table = Terminal::Table.new(
          headings: serializer_cls.attributes.map(&:to_s).map(&:upcase),
          rows: new_entries.map(&:values)
        )
        puts table
      end

      # @return [Class<Kerbi::Cli::EntrySerializer>]
      def serializer_cls
        Kerbi::Cli::EntrySerializer
      end
    end
  end
end