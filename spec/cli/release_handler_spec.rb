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

  describe "$ kerbi release status [RELEASE_NAME]" do
    let(:cmd) { "release status #{release_name}" }
    context "when everything is ready" do
      it "echoes the correct text" do
        exp_cli_eq_file(cmd, exps_dir, "status-all-working")
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
    it "works" do
      puts cli("release list")
    end
  end
end