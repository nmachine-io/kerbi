require_relative './../spec_helper'

RSpec.describe Kerbi::State::Entry do

  let(:subject_cls) { Kerbi::State::Entry }

  let(:default_dict) do
    {
      tag: "tag",
      message: "message",
      values: {x: {y: "z"}},
      created_at: "2020-01-02T03:04:00",
    }
  end

  describe ".from_dict" do
    it "parses the created_at timestamp correctly" do
      entry = subject_cls.from_dict(default_dict)
      expected = Time.new(2020, 1, 2, 3, 4, 0)
      expect(entry.created_at).to eq(expected)
    end
  end
end