require_relative './../spec_helper'

RSpec.describe Kerbi::State::ConfigMapBackend do

  def make_subject(namespace)
    Kerbi::State::ConfigMapBackend.new(
      Kerbi::Utils::K8sAuth.kube_config_bundle,
      namespace
    )
  end

  describe "#template_resource" do
    it "works" do
      thing = make_subject("default")
      puts thing.template_resource([])
    end
  end

end