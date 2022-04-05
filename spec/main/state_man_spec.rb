require_relative './../spec_helper'

RSpec.describe Kerbi::State::ConfigMapBackend do

  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::Consts::RESOURCE_NAME }

  def kmd(command)
    opts = { err: File::NULL, out: File::NULL }
    system("kubectl #{command} --context kind-kind", **opts)
  end

  before :each do
    kmd("create ns #{namespace}")
    kmd("delete cm #{cm_name} -n #{namespace}")
    # sleep(2) #ADD ME BACK IF WEIRD ERRORS... :/
  end

  # @return [Kerbi::State::ConfigMapBackend]
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

    context "with some entries (for puts only, uncomment)" do
      it "puts it" do
        # entry = new_state("1", created_at: "2022-01-01T00:00:00+00:00")
        # puts entry.to_h
        # result = make_subject("xyz").template_resource([entry])
        # puts result
      end
    end
  end

  describe "#namespace_exists?" do
    context "when the namespace exists" do
      it "returns true" do
        expect(make_subject("default").namespace_exists?).to be_truthy
      end
    end
    context "when the namespace does not exist" do
      it "returns false" do
        expect(make_subject("nope").namespace_exists?).to be_falsey
      end
    end
  end

  describe "#apply_resource and #read_entries" do
    let(:entries) do
      [
        new_state("one", message: "m-one", created_at: "2022-01-01T00:00:00+00:00"),
        new_state("two", message: "m-two", created_at: "2022-02-01T00:00:00+00:00"),
      ]
    end

    it "creates a configmap with the right contents" do
      subject = make_subject(namespace)
      descriptor = subject.template_resource(entries)
      subject.apply_resource(descriptor)
      sleep(1)
      actual = subject.send(:read_entries)
      expect(actual.count).to eq(2)

      actual_one = actual[0].values_at("tag", "message", "created_at")
      expected_one = entries[0].to_h.values_at(:tag, :message, :created_at)
      expect(actual_one).to eq(expected_one)
    end
  end
end