require_relative './../spec_helper'

RSpec.describe Kerbi::State::ConfigMapBackend do

  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::Consts::RESOURCE_NAME }

  def mk_entry(opts={})
    default = {
      tag: "tag",
      message: "message",
      values: {x: {y: "z"}},
      created_at: "2022-01-01T00:00:00+00:00",
    }
    Kerbi::State::Entry.from_dict(default.merge(opts))
  end

  def kmd(command)
    opts = { err: File::NULL, out: File::NULL }
    system("kubectl #{command} --context kind-kind", **opts)
  end

  before :each do
    kmd("create ns #{namespace}")
    kmd("delete cm #{cm_name} -n #{namespace}")
    sleep(2)
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
        mk_entry(tag: "1", created_at: "2022-01-01T00:00:00+00:00"),
        mk_entry(tag: "2", created_at: "2022-02-01T00:00:00+00:00"),
      ]
    end

    let(:expected) { entries.map(&:serialize).reverse }

    it "creates a configmap with the right contents" do
      subject = make_subject(namespace)
      descriptor = subject.template_resource(entries)
      subject.apply_resource(descriptor)
      sleep(1)
      entries = subject.read_entries
      serialized_entries = entries.map(&:serialize)
      expect(serialized_entries).to eq(expected)
      expect(entries[0].latest?).to be_truthy
      expect(entries[1].latest?).to be_falsey
    end
  end

  describe "#read_entries" do
    it "works" do
      subject = make_subject(namespace)
      result = subject.read_entries
      puts result
      puts result.map(&:serialize)
    end
  end
end