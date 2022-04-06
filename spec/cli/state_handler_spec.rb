require_relative './../spec_helper'

RSpec.describe Kerbi::Cli::StateHandler do

  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::Consts::RESOURCE_NAME }
  let(:exps_dir) { "state_handler" }

  let(:set) do
    new_state_set(
      one: { values: {x: "x"}, created_at: Time.new(2000).to_s },
      two: { message: "message", created_at: Time.new(2001).to_s },
      "[cand]-one".to_sym => { created_at: Time.new(2002).to_s },
      "[cand]-two".to_sym => { created_at: Time.new(2003).to_s }
    )
  end

  before :each do
    kmd("create ns #{namespace}")
    kmd("delete cm #{cm_name} -n #{namespace}")
    backend = make_backend(namespace)
    configmap_dict = backend.template_resource(set.entries)
    backend.apply_resource(configmap_dict)
  end

  describe "#init" do
  end

  describe "#list" do
    let(:cmd) { "state list -n #{namespace}" }

    context "with --output-format=json" do
      it "outputs the expected text" do
        expect_cli_eq_file("#{cmd} -o json", exps_dir, "list", "json")
      end
    end

    context "with --output-format=yaml" do
      it "outputs the expected text" do
        expect_cli_eq_file("#{cmd} -o yaml", exps_dir, "list", "yaml")
      end
    end

    context "with --output-format=table" do
      it "outputs the expected text" do
        expect_cli_eq_file("#{cmd} -o table", exps_dir, "list", "txt")
      end
    end
  end

end