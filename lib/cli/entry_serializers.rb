module Kerbi
  module Cli
    module EntrySerializationHelpers
      def defined_or_na(actual_value)
        if !(value = actual_value).nil?
          if block_given?
            begin
              yield(value)
            rescue
              "ERR"
            end
          else
            value
          end
        else
          "N/A"
        end
      end

      def colored_tag
        #noinspection RubyResolve
        color = object.committed? ? :blue : :yellow
        object.tag.colorize(color)
      end

    end

    class EntryYamlJsonSerializer < Kerbi::Cli::BaseSerializer
      include Kerbi::Cli::EntrySerializationHelpers

      has_attributes(
        :tag,
        :message,
        :created_at,
        :values,
        :default_values,
        :overridden_keys
      )
    end

    class FullEntryRowSerializer < Kerbi::Cli::BaseSerializer
      include Kerbi::Cli::EntrySerializationHelpers

      has_attributes(
        :tag,
        :message,
        :created_at,
        :values,
        :default_values,
        :overridden_keys
      )

      def tag
        #noinspection RubyResolve
        colored_tag.bold
      end
    end

    class EntryRowSerializer < Kerbi::Cli::BaseSerializer
      include Kerbi::Cli::EntrySerializationHelpers

      has_attributes(
        :tag,
        :message,
        :assignments,
        :overrides,
        :created_at
      )

      def tag
        colored_tag
      end

      def message
        (object.message || "").truncate(27)
      end

      def assignments
        defined_or_na(object.values) do |values|
          Kerbi::Utils::Misc.flatten_hash(values).count
        end
      end

      def overrides
        defined_or_na(object.overrides_delta) do |differences|
          Kerbi::Utils::Misc.flatten_hash(differences).count
        end
      end

      def created_at
        if object.created_at
          Kerbi::Utils::Misc.pretty_time_elapsed(object.created_at)
        else
          "N/A"
        end
      end
    end
  end
end