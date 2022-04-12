require_relative 'consts'
require_relative 'helpers'

module HelloKerbi
  class Mixer < Kerbi::Mixer
    include Helpers

    locate_self __dir__

    def mix
      patched_with file("common/metadata") do
        push file("pod-and-service")
      end
    end
  end
end

Kerbi::Globals.mixers << HelloKerbi::Mixer