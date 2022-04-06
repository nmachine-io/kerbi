module Kerbi
  module Cli
    class StateHandler < BaseHandler
      cmd_meta Kerbi::Consts::CommandSchemas::INIT_STATE
      # @param [String] namespace refers to a Kubernetes namespace
      def init(namespace)
        state_backend(namespace).provision_missing_resources(
          verbose: run_opts.verbose?
        )
        ns_key = Kerbi::Consts::OptionSchemas::NAMESPACE
        Kerbi::ConfigFile.patch({ns_key => namespace})
      end

      cmd_meta Kerbi::Consts::CommandSchemas::STATE_STATUS
      def status
        state_backend.test_connection(verbose: run_opts.verbose?)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::LIST_STATE
      def list
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        echo_data(
          state_backend.entries,
          table_serializer: Kerbi::Cli::EntryRowSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      cmd_meta Kerbi::Consts::CommandSchemas::SHOW_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def show(tag_expr)
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        entry = find_readable_entry(tag_expr)
        echo_data(
          entry,
          table_serializer: Kerbi::Cli::FullEntryRowSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      cmd_meta Kerbi::Consts::CommandSchemas::RETAG_STATE
      # @param [String] old_tag_expr e.g 1.9.1, @latest
      # @param [String] new_tag_expr e.g 1.9.1, @latest
      def retag(old_tag_expr, new_tag_expr)
        entry = find_readable_entry(old_tag_expr)
        old_tag = entry.retag(new_tag_expr)
        touch_and_save_entry(entry, tag: old_tag)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::PROMOTE_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def promote(tag_expr)
        entry = find_readable_entry(tag_expr)
        old_name = entry.promote
        touch_and_save_entry(entry, tag: old_name)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::DEMOTE_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def demote(tag_expr)
        entry = find_readable_entry(tag_expr)
        old_name = entry.demote
        touch_and_save_entry(entry, tag: old_name)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::SET_STATE_ATTR
      # @param [String] tag_expr e.g 1.9.1, @latest
      # @param [String] attr_name e.g message
      # @param [String] new_value e.g i am a new message
      def set(tag_expr, attr_name, new_value)
        entry = find_readable_entry(tag_expr)
        old_value = entry.assign_attr(attr_name, new_value)
        touch_and_save_entry(entry, attr_name => old_value)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::DELETE_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def delete(tag_expr)
        entry = find_readable_entry(tag_expr)
        state_backend.delete_entry(entry)
        new_count = state_backend.entries.count
        puts "Deleted state[#{entry.tag}]. Remaining entries: #{new_count}"
      end

      cmd_meta Kerbi::Consts::CommandSchemas::PRUNE_CANDIDATES_STATE
      def prune_candidates
        old_count = entry_set.entries.count
        entry_set.prune_candidates
        state_backend.save
        new_count = entry_set.entries.count
        puts "Pruned #{old_count - new_count} state entries"
      end
    end
  end
end
