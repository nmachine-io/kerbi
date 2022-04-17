require_relative './../spec_helper'

RSpec.describe "$ kerbi state [COMMAND]" do

  let(:namespace) { "kerbi-spec" }
  let(:release_name) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::ConfigMapBackend.mk_cm_name(release_name) }
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
    create_ns(release_name)
    delete_cm(cm_name, namespace)
    backend = make_backend(release_name, namespace)
    configmap_dict = backend.template_resource(set.entries)
    backend.apply_resource(configmap_dict)
  end

  describe "$ kerbi state list [RELEASE_NAME]" do
    cmd_group_spec("state list kerbi-spec", "state", "list")
  end

  describe "$ kerbi state show [RELEASE_NAME] [TAG]" do
    cmd_group_spec(
      "state show kerbi-spec one",
      "state",
      "show"
    )

    cmd_group_spec(
      "state show kerbi-spec @oldest",
      "state",
      "show",
      context_append: "using @oldest instead of a literal tag"
    )
  end

  describe "$ kerbi state retag [RELEASE_NAME] [OLD_TAG] [NEW_TAG]" do
    def make_cmd(old_tag)
      "state retag #{namespace} #{old_tag} born-again"
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

  describe "$ kerbi state promote [RELEASE_NAME] [TAG]" do
    let(:cmd) { "state promote #{release_name} @candidate" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "promote")
    end
  end

  describe "$ kerbi state demote [RELEASE_NAME] [TAG]" do
    let(:cmd) { "state demote #{release_name} @latest" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "demote")
    end
  end

  describe "$ kerbi state set [RELEASE_NAME] [TAG] [ATTR] [VAL]" do
    let(:easy_part) { "state set #{release_name} @latest message" }
    let(:cmd) { easy_part.split(" ") + ["new message", "-n", namespace] }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "set")
    end
  end

  describe "$ kerbi state delete [RELEASE_NAME] [TAG]" do
    let(:cmd) { "state delete #{release_name} @latest" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "delete")
    end
  end

  describe "$ kerbi state prune-candidates [RELEASE_NAME]" do
    let(:cmd) { "state prune-candidates #{release_name}" }
    it "echos the expected text" do
      exp_cli_eq_file(cmd, exps_dir, "prune-candidates")
    end
  end

end