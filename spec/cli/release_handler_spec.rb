require_relative './../spec_helper'

RSpec.describe "$ kerbi release [COMMAND]" do

  let(:namespace) { "kerbi-spec" }
  let(:release_name) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::ConfigMapBackend.mk_cm_name(release_name) }
  let(:exps_dir) { "release" }

  let(:set) do
    new_state_set(
      one: { values: {x: "x"}, created_at: Time.new(2000).to_s },
      two: { message: "message", created_at: Time.new(2001).to_s },
      "[cand]-three".to_sym => { created_at: Time.new(2002).to_s },
      "[cand]-four".to_sym => { created_at: Time.new(2003).to_s }
    )
  end

  before :each do
    create_ns(release_name)
    delete_cm(cm_name, namespace)
    backend = make_backend(release_name, namespace)
    configmap_dict = backend.template_resource(set.entries)
    backend.apply_resource(configmap_dict)
  end

  describe "$ kerbi release init [RELEASE_NAME]" do
    let(:cmd) { "release init #{release_name}" }
    context "when resources already existed" do
      it "echoes the correct text" do
        exp_cli_eq_file(cmd, exps_dir, "init-already-existed")
      end
    end

    context "when the resources did not exist" do
      it "echoes the correct text" do
        delete_ns(namespace)
        exp_cli_eq_file(cmd, exps_dir, "init-both-created")
      end
    end
  end

  describe "$ kerbi release delete [RELEASE_NAME]" do
    before :each do
      backend = make_backend(release_name, namespace)
      backend.provision_missing_resources
    end

    let(:cmd) { "release delete #{release_name} " \
                "--namespace #{namespace} " \
                "--confirm"
    }

    it "deletes the resource" do
      backend = make_backend(release_name, namespace)
      expect(backend.read_write_ready?).to eq(true)
      backend = make_backend(release_name, namespace)
      exp_cli_eq_file(cmd, exps_dir, "delete")
      expect(backend.read_write_ready?).to eq(false)
    end
  end

  describe "$ kerbi release status [RELEASE_NAME]" do
    let(:cmd) { "release status #{release_name}" }
    context "when resources are provisioned" do
      context "when the data is readable" do
        it "echoes the correct text" do
          exp_cli_eq_file(cmd, exps_dir, "status-all-working")
        end
      end
      context "when the data is not readable" do
        it "echoes the correct text" do
          backend = make_backend(release_name, namespace)
          corrupt_cm(backend)
          exp_cli_eq_file(cmd, exps_dir, "status-data-unreadable")
        end
      end
    end

    context "when connected but resources not provisioned" do
      it "echoes the correct text" do
        delete_ns(namespace)
        exp_cli_eq_file(cmd, exps_dir, "status-not-provisioned")
      end
    end
  end

  describe "$ kerbi release list" do

    before(:each) { delete_ns("kerbi-spec") }

    def provision(release_name, namespace, entry_count)
      backend = make_backend(release_name, namespace)
      backend.provision_missing_resources(quiet: true)
      expect(backend.read_write_ready?).to eq(true)

      if entry_count >= 0
        entries = []
        entry_count.times do |i|
          entries << new_state("#{i + 1}.0.0")
        end
        new_dict = backend.template_resource(entries)
        backend.apply_resource(new_dict, mode: "update")
      else
        corrupt_cm(backend)
      end
    end

    before :all do
      delete_ns("tuna")
      delete_ns("macron")

      provision("tuna", "tuna", 2)
      provision("dirt", "tuna", -1)
      provision("tuna", "macron", 0)
    end

    after :all do
      delete_ns("tuna")
      delete_ns("macron")
    end

    it "works" do
      puts cli("release list")
      exp_cli_eq_file("release list", exps_dir, "list")
    end
  end
end