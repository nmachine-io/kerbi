require_relative './../spec_helper'

RSpec.describe Kerbi::State::ConfigMapBackend do

  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::ConfigMapBackend.mk_cm_name(namespace) }

  before :each do
    create_ns(namespace)
    delete_cm(cm_name, namespace)
    # sleep(2) #ADD ME BACK IF WEIRD ERRORS... :/
  end

  describe "#provision_missing_resources" do
    let(:backend) { make_backend(namespace, namespace) }

    context "when the namespace does not exist" do
      it "provisions accordingly" do
        delete_ns(namespace)
        expect(backend.read_write_ready?).to be_falsey
        backend.provision_missing_resources
      end
    end

    context "when the namespace does exist" do
      before :each do
        create_ns(namespace)
        expect(backend.read_write_ready?).to be_falsey
      end

      context "when the configmap does not exist" do
        it "provisions accordingly" do
          backend.provision_missing_resources
          delete_cm(cm_name, namespace)
          backend.provision_missing_resources
        end
      end

      context "when the configmap does exist" do
        it "provisions accordingly" do
          backend.provision_missing_resources
          backend.provision_missing_resources
        end
      end
    end

    after :each do
      expect(backend.namespace_exists?).to eq(true)
      expect(backend.read_write_ready?).to eq(true)
      expect(backend.resource_exists?).to eq(true)
    end
  end

  describe "#template_resource" do
    context "with 0 entries" do
      it "outputs a descriptor with the right basic properties" do
        result = make_backend("xyz").template_resource([])
        metadata = (result || {})[:metadata] || {}
        expect(result[:kind]).to eq('ConfigMap')
        expect(metadata[:name]).to eq('kerbi-xyz-db')
        expect(metadata[:namespace]).to eq('xyz')
        expect(result[:data][:entries]).to eq("[]")
      end
    end

    context "with some entries (for puts only, uncomment)" do
      it "puts it" do
        # entry = new_state("1", created_at: "2022-01-01T00:00:00+00:00")
        # puts entry.to_h
        # result = make_backend("xyz").template_resource([entry])
        # puts result
      end
    end
  end

  describe "#namespace_exists?" do
    context "when the namespace exists" do
      it "returns true" do
        expect(make_backend('', "default").namespace_exists?).to be_truthy
      end
    end
    context "when the namespace does not exist" do
      it "returns false" do
        expect(make_backend('', "nope").namespace_exists?).to be_falsey
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
      subject = make_backend(namespace, namespace)
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