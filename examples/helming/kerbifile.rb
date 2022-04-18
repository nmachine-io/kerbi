class HelmExample < Kerbi::Mixer
  def mix
    push helm_chart(
           'jetstack/cert-manager',
           release: release_name,
           values: values.dig(:cert_manager)
         )
  end
end

Kerbi::Globals.mixers << HelmExample
