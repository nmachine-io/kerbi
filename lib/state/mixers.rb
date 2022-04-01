module Kerbi
  module State
    class ConfigMapMixer < Kerbi::Mixer
      locate_self __dir__

      def mix
        patched_with file("metadata") do
          push file("resources", only: [{kind: "ConfigMap"}])
        end
      end
    end

    class NamespaceMixer < Kerbi::Mixer
      locate_self __dir__

      def mix
        patched_with file("metadata") do
          push file("resources", only: [{kind: "Namespace"}])
        end
      end
    end
  end
end