require_relative './../spec_helper'
require 'io/console'

RSpec.describe "$ kerbi values [COMMAND]" do
  let(:namespace) { "kerbi-spec" }

  describe "$ kerbi values show" do
    context "without state" do
      it "respects --set > -f > defaults" do
        base = "values show -f v2 -f production --set service.type=NodePort"
        cmd = hello_kerbi(base)
        exp_cli_eq_file(cmd, "values", "order-of-precedence", "yaml")
      end
    end
  end

end