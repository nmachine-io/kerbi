require_relative 'other_mixer'

module MultiMixing
  class MixerOne < Kerbi::Mixer
    def mix
      push(mixer_says: "MixerOne #{values}")
    end
  end

  class OuterMixer < Kerbi::Mixer
    def mix
      push mixer_says: "OuterMixer #{values}"
      push mixer(MultiMixing::MixerOne)
      push mixer(MultiMixing::MixerTwo, values: values[:x])
    end
  end
end

Kerbi::Globals.mixers << MultiMixing::OuterMixer
Kerbi::Globals.revision = "1.0.0"