module Kerbi
  module Cli
    class ValuesHandler < BaseHandler
      thor_meta Kerbi::Consts::CommandSchemas::SHOW_VALUES
      def show
        values = self.compile_values
        persist_compiled_values
        echo_data(values, coerce_type: "Hash")
      end
    end
  end
end
