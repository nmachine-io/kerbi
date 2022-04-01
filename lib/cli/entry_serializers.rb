module Kerbi
  module Cli
    module EntrySerializationHelpers
      def tag
        if object.latest?
          str = "#{object.tag} [latest]"
        else
          str = object.tag
        end
        #noinspection RubyResolve
        str.bold
      end

      def message
        (object.message || "").truncate(27)
      end

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

    class BigEntrySerializer < Kerbi::Cli::BaseSerializer
      include Kerbi::Cli::EntrySerializationHelpers

      has_attributes(
        :tag,
        :message,
        :created_at,
        :values,
        :default_values,
        :differences
      )

      def values
        defined_or_na(object.values) { |v| JSON.dump(v) }
      end

      def default_values
        defined_or_na(object.default_values) { |v| JSON.dump(v) }
      end

      def differences
        defined_or_na(object.default_new_delta) { |v| JSON.dump(v) }
      end
    end

    class EntrySerializer < Kerbi::Cli::BaseSerializer
      include Kerbi::Cli::EntrySerializationHelpers

      has_attributes(
        :tag,
        :message,
        :assignments,
        :overrides,
        :created_at
      )

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