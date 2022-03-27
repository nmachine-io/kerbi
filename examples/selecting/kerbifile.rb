
class FilteringExample < Kerbi::Mixer
  ACCEPT = [{kind: "PersistentVolume.*"}]
  REJECT = [{name: "unwanted"}]

  def mix
    push file('resources', only: ACCEPT, except: REJECT)
  end
end

Kerbi::Globals.mixers << FilteringExample
