require_relative './../spec_helper'

RSpec.describe "$ kerbi config [COMMAND]" do

  before(:each) { Kerbi::ConfigFile.reset }

  describe "$ kerbi config show" do
    it "outputs the expected text" do
      exp_cli_eq_file("config show", "config", "show-default", "yaml")
    end
  end

  describe "$ kerbi config set [ATTR] [VALUE]" do
    let(:cmd) { "config set namespace kerbi-spec" }
    context "for a legal assignment" do
      it "outputs the expected text and changes the value" do
        exp_cli_eq_file(cmd, "config", "set", "txt")
        new_value = Kerbi::ConfigFile.read["namespace"]
        expect(new_value).to eq("kerbi-spec")
      end
    end
    context "for an illegal assignment" do
      let(:cmd){ "config set bad-key fail" }
      it "outputs the expected error message" do
        exp_cli_eq_file(cmd, "config", "bad-set", "txt")
      end
    end
  end

  describe "$ kerbi config get [ATTR]" do
    let(:cmd) { "config get namespace" }
    it "outputs the expected text and changes the value" do
      cli("config set namespace kerbi-spec")
      expect(cli(cmd).gsub(/\s+/, "")).to eq("kerbi-spec")
    end
  end

end