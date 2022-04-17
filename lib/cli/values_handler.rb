module Kerbi
  module Cli
    class ValuesHandler < BaseHandler
      cmd_meta Kerbi::Consts::CommandSchemas::SHOW_VALUES
      def show(release_name, project_uri)
        mem_dna(release_name, project_uri)
        values = compile_values
        persist_compiled_values
        echo_data(values, coerce_type: "Hash")
      end
    end
  end
end
