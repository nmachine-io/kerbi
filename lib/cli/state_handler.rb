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
      def show(tag_expr)
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        entry = find_readable_entry(tag_expr)
        echo_data(
          entry,
          table_serializer: Kerbi::Cli::FullEntryRowSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      thor_meta Kerbi::Consts::CommandSchemas::RETAG_STATE
      def retag(old_tag_expr, new_tag_expr)
        entry = find_readable_entry(old_tag_expr)
        old_tag = entry.retag(new_tag_expr)
        touch_and_save_entry(entry, tag: old_tag)
      end

      thor_meta Kerbi::Consts::CommandSchemas::PROMOTE_STATE
      def promote(tag_expr)
        entry = find_readable_entry(tag_expr)
        old_name = entry.promote
        touch_and_save_entry(entry, tag: old_name)
      end

      thor_meta Kerbi::Consts::CommandSchemas::DEMOTE_STATE
      def demote(tag_expr)
        entry = find_readable_entry(tag_expr)
        old_name = entry.demote
        touch_and_save_entry(entry, tag: old_name)
      end

      def set(tag_expr, field, new_value)
        entry = find_readable_entry(tag_expr)

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
