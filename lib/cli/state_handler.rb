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
        entry = entry_set.find_entry_for_read(tag)
        raise Kerbi::StateNotFoundError unless entry
        echo_data(
          entry,
          table_serializer: Kerbi::Cli::EntryYamlJsonSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      thor_meta Kerbi::Consts::CommandSchemas::RETAG_STATE
      def retag(old_tag_expr, new_tag)
        entry = entry_set.find_entry_for_read(old_tag_expr)
        raise Kerbi::StateNotFoundError unless entry
        entry.tag = new_tag
        entry.created_at = Time.now
        state_backend.save
      end

      thor_meta Kerbi::Consts::CommandSchemas::DELETE_STATE
      def delete(expr)
        entry = entry_set.find_entry_for_read(expr)
        raise Kerbi::StateNotFoundError unless entry
        state_backend.delete_entry(entry)
      end
    end
  end
end
