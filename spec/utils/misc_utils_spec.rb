require_relative './../spec_helper'

RSpec.describe Kerbi::Utils::Misc do

  subject { Kerbi::Utils::Misc }

  describe ".flatten_hash" do
    context 'with an already flat hash' do
      it 'returns the same hash' do
        actual = subject.flatten_hash({foo: 'bar'})
        expect(actual).to eq({foo: 'bar'})
      end
    end

    context 'with a deep hash' do
      it 'returns a flat hash with deep keys' do
        actual = subject.flatten_hash({foo: { bar: 'baz' }})
        expect(actual).to eq({'foo.bar': 'baz'})
      end
    end
  end

  describe ".deep_hash_diff" do
    it "works" do
      result = subject.deep_hash_diff(
        {a: "a"},
        {a: "b"}
      )
    end
  end
end