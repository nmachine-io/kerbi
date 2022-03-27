require_relative './../spec_helper'

class PatchTestOne < Kerbi::Mixer
  def mix
    patched_with({x: {y: "z"}}) do
      push dict(x: {z: "y"})
    end

    push dict(x: {y: "z"})

    patched_with({x: {y: "z", v: "k"}}) do
      patched_with({x: {k: "v"}}) do
        push dict(x: {z: "y"})
      end
      push dict(x: {z: "y"})
    end
  end
end

class PatchTestTwo < Kerbi::Mixer
  def mix
    patched_with({x: {y: "z", v: "k"}}) do
      patched_with({x: {k: "v"}}) do
        push dict(x: {z: "y"})
      end
      push dict(x: {z: "y"})
    end
  end
end

RSpec.describe Kerbi::Mixer do

  subject { Kerbi::Mixer.new({}) }

  before :each do
    Kerbi::Testing.reset_test_yamls_dir
    Kerbi::Mixer.locate_self Kerbi::Testing::TEST_YAMLS_DIR
  end

  describe "#patched_with" do
    let(:mixer) { PatchTestOne.new({}) }
    it "correctly patches output in the yielded block" do
      expect(mixer.run.first).to eq({x: {z: "y", y: "z"}})
      expect(mixer.patch_stack.count).to eq(0)
    end

    it "does not patch out-of-block dicts" do
      expect(mixer.run[1]).to eq({x: {y: "z"}})
      expect(mixer.patch_stack.count).to eq(0)
    end

    it "handles nested patches correctly" do
      expect(mixer.run[2]).to eq({x: {z: "y", y: "z", v: "k", k: "v"}})
      expect(mixer.patch_stack.count).to eq(0)

      expect(mixer.run[3]).to eq({x: {z: "y", y: "z", v: "k"}})
      expect(mixer.patch_stack.count).to eq(0)
    end

    it "does not affect calls that are themselves patches" do

    end
  end

  describe "#push" do
    let(:expected) { [{x: "y"}, {y: 'z'}] }
    it "pushes" do
      subject.push({x: "y"})
      subject.push(nil)
      subject.push([{y: 'z'}, "not-a-dict"])
      expect(subject.output).to match_array(expected)
    end
  end

  describe "#dict" do
    it "returns the right result" do
      result = subject.dict({foo: "bar"})
      expect(result).to eq([{foo: "bar"}])
    end
    it "delegates to Utils::Mixing" do
      expect(Kerbi::Utils::Mixing).to receive(:clean_and_filter_dicts)
      subject.dict({foo: "bar"})
    end
  end

  describe "#file" do
    let(:values) { { foo: "zar" } }
    subject { Kerbi::Mixer.new(values) }

    it "works" do
      Kerbi::Testing.reset_test_yamls_dir
      Kerbi::Testing.make_yaml("foo.yaml", "foo: <%= values[:foo] %>")
      result = subject.file("foo.yaml")
      expect(result).to eq([{foo: "zar"}])
    end
  end

  describe "#resolve_file_name" do
    subject { Kerbi::Mixer }

    context 'when fname is not a real file' do
      it 'returns the assumed fully qualified name' do
        expect(subject.resolve_file_name('bar')).to eq(nil)
      end
    end

    context 'when fname is a real file' do
      it 'returns the original fname'do
        Kerbi::Testing.make_yaml('foo.yaml', {})
        expected = "#{Kerbi::Testing::TEST_YAMLS_DIR}/foo.yaml"
        expect(subject.resolve_file_name(expected)).to eq(expected)
        expect(subject.resolve_file_name('foo')).to eq(expected)
        expect(subject.resolve_file_name('foo.yaml')).to eq(expected)
      end
    end
  end

  describe ".locate_self" do
    it "stores and later outputs the value" do
      class Subclass < Kerbi::Mixer
        locate_self 'foo'
      end
      expect(Subclass.new({}).class.pwd).to eq('foo')
    end
  end
end