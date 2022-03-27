module Kerbi
  module Examples
    class HelloWorld < Kerbi::Mixer
      def mix
        push file("pod")
      end
    end
  end
end

Kerbi::Globals.mixers << Kerbi::Examples::HelloWorld
