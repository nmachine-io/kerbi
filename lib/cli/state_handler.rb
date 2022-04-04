module Kerbi
  module Cli
    class StateHandler < BaseHandler
      thor_meta Kerbi::Consts::CommandSchemas::INIT_STATE
      def init(namespace)
        state_backend(namespace).provision_missing_resources(
          verbose: run_opts.verbose?
        )
        ns_key = Kerbi::Consts::OptionSchemas::NAMESPACE
        Kerbi::ConfigFile.patch(ns_key => namespace)
      end

      thor_meta Kerbi::Consts::CommandSchemas::STATE_STATUS
      def status
        state_backend.test_connection(verbose: run_opts.verbose?)
      end

      thor_meta Kerbi::Consts::CommandSchemas::LIST_STATE
      def list
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        echo_data(
          state_backend.entries,
          table_serializer: Kerbi::Cli::EntryRowSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      thor_meta Kerbi::Consts::CommandSchemas::SHOW_STATE
      def show(tag)
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        entry = find_entry(tag)
        echo_data(
          entry,
          table_serializer: Kerbi::Cli::EntryYamlJsonSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      thor_meta Kerbi::Consts::CommandSchemas::DELETE_STATE
      def delete(expr)
        if(entry = find_entry(expr))

        end
      end
    end
  end
end
