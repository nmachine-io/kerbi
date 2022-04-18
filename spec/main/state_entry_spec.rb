require_relative './../spec_helper'

RSpec.describe Kerbi::State::Entry do

  let(:subject_cls) { Kerbi::State::Entry }
  let(:cand_prefix) { subject_cls::CANDIDATE_PREFIX }

  let(:default_dict) do
    {
      tag: "tag",
      message: "message",
      values: {x: {y: "z"}},
      revision: nil,
      default_values: {y: "z"},
      created_at: "2020-01-02T03:04:00",
    }
  end

  describe "#candiate? and #committed?" do
    context "when it is a candidate" do
      it "returns true for #candidate and false for #committed" do
        expect(new_state("[cand]-one").candidate?).to be_truthy
        expect(new_state("[cand]-one").committed?).to be_falsey
      end
    end
    context "when it is a candidate" do
      it "returns false for #candidate and true for #committed" do
        expect(new_state("[cant]-one").candidate?).to be_falsey
        expect(new_state("[cant]-one").committed?).to be_truthy
      end
    end
  end

  describe "#validate" do
    context "when there is a tag error" do
      it "finds validation errors" do
        (state = new_state("")).validate
        expect(state.valid?).to be_falsey

        (state = new_state("  ")).validate
        expect(state.valid?).to be_falsey
      end
    end

    context "when there are zero tag errors" do
      it "finds validation errors" do
        (state = new_state("a")).validate
        expect(state.valid?).to be_truthy

        (state = new_state("|")).validate
        expect(state.valid?).to be_truthy
      end
    end
  end

  describe "#promote" do
    context "when the entry is a candidate" do
      it "removes the [cand]- flag" do
        old = (state = new_state("#{cand_prefix}foo")).promote
        expect(state.tag).to eq("foo")
        expect(old).to eq("#{cand_prefix}foo")
      end
    end

    context "when the entry is not a candidate" do
      it "raises" do
        expect {
          new_state("foo").promote
        }.to raise_exception(Kerbi::StateNotPromotable)
      end
    end
  end

  describe "#demote" do
    context "when the entry is committed" do
      it "adds the [cand]- flag" do
        old = (state = new_state("foo")).demote
        expect(state.tag).to eq("#{cand_prefix}foo")
        expect(old).to eq("foo")
      end
    end

    context "when the entry is not a candidate" do
      it "raises" do
        expect {
          new_state("#{cand_prefix}foo").demote
        }.to raise_exception(Kerbi::StateNotDemotable)
      end
    end
  end

  describe ".from_dict" do
    it "parses the created_at timestamp correctly" do
      entry = subject_cls.from_dict(nil, default_dict)
      expected = Time.new(2020, 1, 2, 3, 4, 0)
      expect(entry.created_at).to eq(expected)
    end
  end

  describe "#to_h" do
    it "returns the right dict" do
      entry = new_state("foo", default_dict)
      actual = entry.to_h
      actual.delete(:created_at)
      expect = default_dict.deep_dup
      expect.delete(:created_at)
      expect(actual).to eq(expect)
    end
  end
end