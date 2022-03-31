require_relative './../spec_helper'

RSpec.describe Kerbi::State::ConfigMapBackend do

  def make_subject(namespace)
    Kerbi::State::ConfigMapBackend.new(
      Kerbi::Utils::K8sAuth.kube_config_bundle,
      namespace
    )
  end

  describe "#template_resource" do
    context "with 0 entries" do
      it "outputs a descriptor with the right basic properties" do
        result = make_subject("xyz").template_resource([])
        expect(result[:kind]).to eq('ConfigMap')
        expect(result[:metadata][:name]).to eq('kerbi-state-tracker')
        expect(result[:metadata][:namespace]).to eq('xyz')
        expect(result[:data][:entries]).to eq("[]")
      end
    end
  end

  describe "#apply_resource" do
    it "works" do
      subject = make_subject("default")
      descriptor = subject.template_resource([{foo: "bar"}])
      subject.apply_resource(descriptor)
    end
  end

  describe "#read_entries" do
    it "works" do
      subject = make_subject("default")
      result = subject.read_entries
      puts result
      puts result.class
    end
  end

end