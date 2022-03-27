class HelmExample < Kerbi::Mixer
  def mix
    push cert_manager_resources
  end

  def cert_manager_resources
    chart(
      'jetstack/cert-manager',
      release: release_name,
      values: values.dig(:cert_manager)
    )
  end
end

Kerbi::Globals.mixers << HelmExample
