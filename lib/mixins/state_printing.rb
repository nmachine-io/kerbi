module Kerbi
  module Mixins
    module StatePrinting

      HEADER_COLS = [
        { key: :tag, name: "Tag" },
        { key: :message, name: "Message" },
        { key: :tag, name: "Tag" },
        { key: :tag, name: "Tag" },
      ]

      # @param [Array<Kube::State::Entry>] entries
      def print_state_list(entries)
        if cli_opts.output_format("table") == 'table'
          print_state_table(entries)
        else
          print_dicts(entries)
        end
      end

      # @param [Array<Kube::State::Entry>] entries
      def print_state_table(entries)
        table = Terminal::Table.new(
          headings: header,
          rows: entries.map{|_, v|v}
        )
        puts table
      end

      # @param [Kerbi::State::Entry] entry
      # @param [Integer] index assuming sorted DESC by created_at
      def tx(entry, index)

      end
    end
  end
end