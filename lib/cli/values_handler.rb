module Kerbi
  module Cli
    class ValuesHandler < BaseHandler
      thor_meta Kerbi::Consts::CommandSchemas::SHOW_VALUES
      def show
        values = self.compile_values
        print_dicts(values)
      end
    end
  end
end
