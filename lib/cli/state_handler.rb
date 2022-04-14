module Kerbi
  module Cli
    class StateHandler < BaseHandler
      cmd_meta Kerbi::Consts::CommandSchemas::LIST_STATE
      def list(release_name)
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        mem_release_name(release_name)
        echo_data(
          state_backend.entries,
          table_serializer: Kerbi::Cli::EntryRowSerializer,
          serializer: Kerbi::Cli::EntryYamlJsonSerializer
        )
      end

      cmd_meta Kerbi::Consts::CommandSchemas::SHOW_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def show(release_name, tag_expr)
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        mem_release_name(release_name)
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
      def retag(release_name, old_tag_expr, new_tag_expr)
        mem_release_name(release_name)
        entry = find_readable_entry(old_tag_expr)
        old_tag = entry.retag(new_tag_expr)
        touch_and_save_entry(entry, tag: old_tag)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::PROMOTE_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def promote(release_name, tag_expr)
        mem_release_name(release_name)
        entry = find_readable_entry(tag_expr)
        old_name = entry.promote
        touch_and_save_entry(entry, tag: old_name)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::DEMOTE_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def demote(release_name, tag_expr)
        mem_release_name(release_name)
        entry = find_readable_entry(tag_expr)
        old_name = entry.demote
        touch_and_save_entry(entry, tag: old_name)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::SET_STATE_ATTR
      # @param [String] tag_expr e.g 1.9.1, @latest
      # @param [String] attr_name e.g message
      # @param [String] new_value e.g i am a new message
      def set(release_name, tag_expr, attr_name, new_value)
        mem_release_name(release_name)
        entry = find_readable_entry(tag_expr)
        old_value = entry.assign_attr(attr_name, new_value)
        touch_and_save_entry(entry, attr_name => old_value)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::DELETE_STATE
      # @param [String] tag_expr e.g 1.9.1, @latest
      def delete(release_name, tag_expr)
        mem_release_name(release_name)
        entry = find_readable_entry(tag_expr)
        state_backend.delete_entry(entry)
        new_count = state_backend.entries.count
        puts "Deleted state[#{entry.tag}]. Remaining entries: #{new_count}"
      end

      cmd_meta Kerbi::Consts::CommandSchemas::PRUNE_CANDIDATES_STATE
      def prune_candidates(release_name)
        mem_release_name(release_name)
        old_count = entry_set.entries.count
        entry_set.prune_candidates
        state_backend.save
        new_count = entry_set.entries.count
        puts "Pruned #{old_count - new_count} state entries"
      end
    end
  end
end
