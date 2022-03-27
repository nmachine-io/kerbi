class PatchingExample < Kerbi::Mixer
  def mix
    patched_with file('annotations') do
      push file("pod")
    end
  end
end

Kerbi::Globals.mixers << PatchingExample
