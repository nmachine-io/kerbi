require_relative './../spec_helper'

RSpec.describe "$ kerbi state [COMMAND]" do

  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::Consts::RESOURCE_NAME }
  let(:exps_dir) { "state" }

  let(:set) do
    new_state_set(
      one: { values: {x: "x"}, created_at: Time.new(2000).to_s },
      two: { message: "message", created_at: Time.new(2001).to_s },
      "[cand]-three".to_sym => { created_at: Time.new(2002).to_s },
      "[cand]-four".to_sym => { created_at: Time.new(2003).to_s }
    )
  end

  before :each do
    kmd("create ns #{namespace}")
    kmd("delete cm #{cm_name} -n #{namespace}")
    backend = make_backend(namespace)
    configmap_dict = backend.template_resource(set.entries)
    backend.apply_resource(configmap_dict)
  end

  describe "$ kerbi state init" do
    let(:cmd) { "state init kerbi-spec" }
    context "when resources already existed" do
      it "echoes the correct text" do
        exp_cli_eq_file(cmd, exps_dir, "init-already-existed")
      end
    end

    context "when the resources did not exist" do
      it "echoes the correct text" do
        kmd("delete ns #{namespace}")
        exp_cli_eq_file(cmd, exps_dir, "init-both-created")
      end
    end
  end

  describe "$ kerbi state status" do
    let(:cmd) { "state status -n #{namespace}" }
    context "when everything is ready" do
      it "echoes the correct text" do
        exp_cli_eq_file(cmd, exps_dir, "status-all-working")
      end
    end

    context "when connected but resources not provisioned" do
      it "echoes the correct text" do
        kmd("delete ns #{namespace}")
        exp_cli_eq_file(cmd, exps_dir, "status-not-provisioned")
      end
    end
  end

  describe "$ kerbi state list" do
    cmd_group_spec("state list -n kerbi-spec", "state", "list")
  end

  describe "$ kerbi state show [TAG]" do
    cmd_group_spec(
      "state show one -n kerbi-spec",
      "state",
      "show"
    )

    cmd_group_spec(
      "state show @oldest -n kerbi-spec",
      "state",
      "show",
      context_append: " using @oldest instead of a literal tag"
    )
  end

  describe "$ kerbi state retag [OLD_TAG] [NEW_TAG]" do
    def make_cmd(old_tag)
      "state retag #{old_tag} born-again -n #{namespace}"
    end

    context "when the old tag exists" do
      context "using a literal tag" do
        it "echos the expected text" do
          exp_cli_eq_file(make_cmd("two"), exps_dir, "retag")
        end
      end

      context "using @latest or @oldest" do
        it "echos the expected text" do
          exp_cli_eq_file(make_cmd("@latest"), exps_dir, "retag")
        end
      end
    end

    context "when the old tag does not exist" do
      it "echos the expected text" do
        exp_cli_eq_file(make_cmd("bad-tag"), "common", "bad-tag")
      end
    end
  end

  describe "$ kerbi state promote" do
    let(:cmd) { "state promote @candidate -n #{namespace}" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "promote")
    end
  end

  describe "$ kerbi state demote" do
    let(:cmd) { "state demote @latest -n #{namespace}" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "demote")
    end
  end

  describe "$ kerbi state set" do
    let(:easy_part) { "state set @latest message" }
    let(:cmd) { easy_part.split(" ") + ["new message", "-n", namespace] }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "set")
    end
  end

  describe "$ kerbi state delete" do
    let(:cmd) { "state delete @latest -n #{namespace}" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "delete")
    end
  end

  describe "$ kerbi state prune-candidates" do
    let(:cmd) { "state prune-candidates -n #{namespace}" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "prune-candidates")
    end
  end

end