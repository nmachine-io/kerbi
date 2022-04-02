module Kerbi
  module Cli
    class StateHandler < BaseHandler
      thor_meta Kerbi::Consts::CommandSchemas::INIT_STATE
      def init
        state_backend.provision_missing_resources(
          verbose: run_opts.verbose?
        )
      end

      thor_meta Kerbi::Consts::CommandSchemas::TEST_STATE
      def status
        state_backend.test_connection(verbose: run_opts.verbose?)
      end

      thor_meta Kerbi::Consts::CommandSchemas::LIST_STATE
      def list
        echo_data(
          state_backend.read_entries,
          table_serializer: Kerbi::Cli::EntryRowSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      thor_meta Kerbi::Consts::CommandSchemas::SHOW_STATE
      def show(tag)
        entry = find_entry(tag)
        echo_data(
          entry,
          table_serializer: Kerbi::Cli::EntryYamlJsonSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end
    end
  end
end
