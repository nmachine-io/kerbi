require_relative './../spec_helper'
require_relative './../../examples/hello-dicts/kerbifile'

RSpec.describe "Examples Directory" do
  describe "The mixer" do
    describe "#run" do
      it "runs" do
        puts Kerbi::Globals.mixers.first.new({ }).run
      end
    end
  end
end