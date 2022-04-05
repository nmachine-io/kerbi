require_relative './../spec_helper'

RSpec.describe Kerbi::State::EntrySet do

  let(:set) do
    new_state_set(
      one: { created_at: Time.new(2000).to_s },
      two: { created_at: Time.new(2001).to_s },
      "[cand]-one".to_sym => { created_at: Time.new(2002).to_s },
      "[cand]-two".to_sym => { created_at: Time.new(2003).to_s }
    )
  end

  let(:bad_set) do
    new_state_set(
      "".to_sym => { },
    )
  end

  describe "#initialize" do
    it "sorts DESC on created_at" do
      expect(set.entries[0].tag).to eq("[cand]-two")
    end
  end

  describe "validate!" do
    context "when there are no errors" do
      it "does not raise an error" do
        set.validate!
      end
    end

    context "when there are errors" do
      it "raises the right error" do
        expect{
          bad_set.validate!
        }.to raise_exception(Kerbi::EntryValidationError)
      end
    end
  end

  describe "#latest" do
    it "returns the correct entry" do
      expect(set.latest.tag).to eq("two")
    end
  end

  describe "#latest_candidate" do
    it "returns the correct entry" do
      expect(set.latest_candidate.tag).to eq("[cand]-two")
    end
  end

  describe "#candidates" do
    it "returns the right entries" do
      expected = %w[[cand]-two [cand]-one]
      expect(set.candidates.map(&:tag)).to eq(expected)
    end
  end

  describe "#committed" do
    it "returns the right entries" do
      expected = %w[two one]
      expect(set.committed.map(&:tag)).to eq(expected)
    end
  end

  describe "#find_entry_for_read" do
    context "when the substitutions work and the entry exists" do
      it "returns the right entry" do
        actual = set.find_entry_for_read("two")
        expect(actual.tag).to eq("two")

        actual = set.find_entry_for_read("@latest")
        expect(actual.tag).to eq("two")

        actual = set.find_entry_for_read("@candidate")
        expect(actual.tag).to eq("[cand]-two")
      end
    end

    context "when either the resolution fails or the entry does not exist" do
      it "raises Kerbi::StateNotFoundError" do
        expect {
          set.find_entry_for_read("three")
        }.to raise_exception(Kerbi::StateNotFoundError)

        expect {
          set.find_entry_for_read("not-@latest")
        }.to raise_exception(Kerbi::StateNotFoundError)
      end
    end
  end

  describe "#find_or_init_entry_for_write" do
    it "returns the right entry" do
      actual = set.find_or_init_entry_for_write("two")
      expect(actual.tag).to eq("two")

      actual = set.find_or_init_entry_for_write("@latest")
      expect(actual.tag).to eq("two")

      actual = set.find_or_init_entry_for_write("@candidate")
      expect(actual.tag).to eq("[cand]-two")

      actual = set.find_or_init_entry_for_write("@new-candidate")
      expect(actual.tag).to_not eq("[cand]-two")
      expect(actual.tag).to_not be_falsey
    end
  end

end