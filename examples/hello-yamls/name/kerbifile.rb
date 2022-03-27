module Name
  class RootMixer < Kerbi::Mixer
    def mix
      push dict(hello: values[:message])
    end
  end
end

Kerbi::Globals.mixers << Name::RootMixer