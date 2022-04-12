require_relative './../spec_helper'

RSpec.describe Kerbi::Utils::K8sAuth do
  #
  # def make_client(bundle)
  #   Kubeclient::Client.new(
  #     bundle[:endpoint],
  #     "v1",
  #     **bundle[:options]
  #   )
  # end
  #
  # describe ".kube_config_client" do
  #   context "with valid kube-config options" do
  #     context "using the system default" do
  #       it "returns a working client" do
  #         bundle = subject.kube_config_bundle(path: nil, name: nil)
  #         namespaces = make_client(bundle).get_namespaces
  #         expect(namespaces.any?).to be_truthy
  #       end
  #     end
  #   end
  #
  #   context "with an invalid kube-config options" do
  #     it "returns a working client" do
  #       expect {
  #         subject.kube_config_bundle(path: "bad-path")
  #       }. to raise_exception(Exception)
  #     end
  #   end
  # end
end