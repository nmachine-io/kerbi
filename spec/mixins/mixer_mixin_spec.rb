require_relative './../spec_helper'

RSpec.describe Kerbi::Mixins::Mixer do

  subject { Kerbi::Mixer.new({}) }

  describe "#embed" do
    subject { Kerbi::EmbeddingMixerTest.new({}) }
    let(:expected) do
      {
        dict: { embedded: "scalar" },
        list: ["item"],
        dict_list: [{ embedded: "item" }]
      }
    end

    it "embeds the values correctly" do
      result = subject.run
      expect(result).to eq([expected])
    end
  end

  describe "#b64enc" do
    it "base 64 encodes the value" do
      mixer = Kerbi::Mixer.new({})
      result = mixer.b64enc("hello world")
      expect(result).to eq("aGVsbG8gd29ybGQ=")
    end
  end

  describe '#b64enc' do
    context 'when the value is truthy' do
      it 'returns the base64 encoding' do
        expect(subject.b64enc('demo')).to eq("ZGVtbw==")
      end
    end
    context 'when the value is blank or nil' do
      it 'returns an empty string' do
        expect(subject.b64enc('')).to eq('')
        expect(subject.b64enc(nil)).to eq('')
      end
    end
  end


end

module Kerbi
  class EmbeddingMixerTest < Kerbi::Mixer
    locate_self "#{Dir.pwd}/spec/fixtures"
    def mix
      push file("embedding")
    end
  end
end
