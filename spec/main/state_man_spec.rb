require_relative './../spec_helper'

RSpec.describe Kerbi::State::ConfigMapBackend do

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

  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::Consts::RESOURCE_NAME }

  before :each do
    kmd("create ns #{namespace}")
    kmd("delete cm #{cm_name} -n #{namespace}")
    sleep(2)
  end

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

  describe "#apply_resource and #read_entries" do
    let(:entries) do
      [
        mk_entry(tag: "1"),
        mk_entry(tag: "2"),
      ]
    end

    let(:expected) { entries.map(&:serialize) }

    it "creates a configmap with the right contents" do
      subject = make_subject(namespace)
      descriptor = subject.template_resource(entries)
      subject.apply_resource(descriptor)
      sleep(1)
      result = subject.read_entries
      expect(result.map(&:serialize)).to match_array(expected)
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