class HelloWorld < Kerbi::Mixer
  def mix
    push dict(its_working: values[:status] || "almost!")
    push dict(fancy_release: "yes!") if release_name != 'default'
  end
end

Kerbi::Globals.mixers << HelloWorld
