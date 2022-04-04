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
    end

    class EntryYamlJsonSerializer < Kerbi::Cli::BaseSerializer
      include Kerbi::Cli::EntrySerializationHelpers

      has_attributes(
        :tag,
        :message,
        :latest?,
        :created_at,
        :values,
        :default_values,
        :default_new_delta
      )
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
        #noinspection RubyResolve
        object.tag.bold
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
        defined_or_na(object.default_new_delta) do |differences|
          Kerbi::Utils::Misc.flatten_hash(differences).count
        end
      end
    end
  end
end