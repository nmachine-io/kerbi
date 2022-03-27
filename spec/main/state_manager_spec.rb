# require_relative './../spec_helper'

# RSpec.describe Kerbi::StateManager do
#
#   subject { Kerbi::StateManager.new }
#
#   context = ENV['KERBI_RSPEC_K8S_CONTEXT'] || 'kind-kind'
#
  # before :each do
  #   puts "KONTEXT #{context}"
  # end
  #
  # describe "#patch" do
  #   context "when there is no entry for variables" do
  #
  #     before :each do
  #       system(
  #         "kubectl delete cm state -n default --context #{context}",
  #         out: File::NULL,
  #         err: File::NULL
  #       )
  #     end
  #
  #     it "patches the configmap" do
  #       argue("--context #{context} --set foo.bar=baz")
  #       old_values = subject.get_crt_vars
  #       expect(old_values).to eq({})
  #       subject.patch
  #       new_values = subject.get_crt_vars
  #       expect(new_values).to eq({foo: {bar: "baz"}})
  #     end
  #   end
  #
  #   context "when there is an entry for variables" do
  #
  #     before :each do
  #       system "kubectl delete cm state -n default --context #{context}"
  #     end
  #
  #     it "patches the configmap" do
  #       argue("--context #{context} --set foo.bar=baz")
  #       subject.patch
  #
  #       argue("--context #{context} --set foo.bar=car")
  #       subject.patch
  #
  #       new_values = subject.get_crt_vars
  #       expect(new_values).to eq({foo: {bar: "car"}})
  #     end
  #
  #   end
  # end
  #
  # describe "#get_configmap" do
  #   context "when it does not exist" do
  #
  #     before :each do
  #       system "kubectl delete cm state -n default --context #{context}"
  #     end
  #
  #     it "returns the configmap as a hash" do
  #       argue("--context #{context}")
  #       result = subject.get_configmap(raise_on_er: false)
  #       expect(result).to be_nil
  #     end
  #   end
  #
  #   context "when it does exist" do
  #     before :each do
  #       system "kubectl create cm state -n default --context #{context}"
  #     end
  #
  #     it "returns the configmap as a hash" do
  #       argue("--context #{context}")
  #       result = subject.get_configmap
  #       expect(result).to_not be_nil
  #       must_have = { name: "state", namespace: "default" }
  #       expect(result[:metadata].slice(:name, :namespace)).to eq(must_have)
  #     end
  #   end
  # end


# end