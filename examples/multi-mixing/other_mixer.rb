module MultiMixing
  class MixerTwo < Kerbi::Mixer
    def mix
      push(mixer_says: "MixerTwo #{values}")
    end
  end
end