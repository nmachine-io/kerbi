require_relative './../spec_helper'

class TestObj
  def get_binding
    binding
  end

  def values
    {k1: "baz"}
  end
end

RSpec.describe Kerbi::Utils::Mixing do

  subject { Kerbi::Utils::Mixing }

  describe ".erb_str_to_dicts" do
    describe 'logic unrelated to filtering' do
      let(:yaml_str) { "k1: <%=extras[:k1]%>\n---\nk1: bar" }
      it 'returns the correct list of hashes' do
        actual = subject.yaml_str_to_dicts(
          yaml_str,
          extras: {k1: "foo"}
        )
        expect(actual).to match_array([{k1: 'foo'}, {k1: 'bar'}])
      end
    end
  end

  describe '.erb_file_to_dicts' do
    context "with well formatted files" do
      let(:fname) { "foo.yaml.erb" }

      before(:each) do
        Kerbi::Testing.reset_test_yamls_dir
        Kerbi::Testing.make_yaml(fname, "k: <%= extras[:foo] %>")
      end

      it 'outputs the correct list of hashes' do
        result = subject.yaml_file_to_dicts(
          Kerbi::Testing.f_fname(fname),
          extras: { foo: "bar" }
        )
        expect(result).to eq([{k: 'bar'}])
      end
    end
  end

  describe ".yamls_in_dir_to_dicts" do
    let(:fname1) { "a.yaml.erb" }
    let(:fname2) { "b.yaml" }
    let(:pwd) { Kerbi::Testing::TEST_YAMLS_DIR }
    let(:expected) { [{bar: "car"}, {foo: "bar"}, {bar: "baz"}] }

    before :each do
      Kerbi::Testing::reset_test_yamls_dir
      Kerbi::Testing.make_yaml(fname1, "foo: bar\n---\nbar: <%= extras[:a] %>")
      Kerbi::Testing.make_yaml(fname2, "bar: car")
    end

    context "without a subdirectory" do
      it "works" do
        result = subject.yamls_in_dir_to_dicts(
          pwd,
          nil,
          extras: { a: "baz" }
        )
        expect(result).to match_array(expected)
      end
    end
  end

  describe ".interpolate_erb_string" do
    context "passing a nil source binding" do

      let(:yaml_str) { "\nfoo: \"<%=extras[:k1]%>\"\n---\nbar: \"bar\"\n" }
      let(:exp_yaml_str) { "\nfoo: \"foo\"\n---\nbar: \"bar\"\n" }

      context "correctly referencing variables" do
        it "works normally" do
          result = subject.interpolate_erb_string(
            yaml_str,
            extras: {k1: "foo"}
          )
          expect(result).to eq(exp_yaml_str)
        end
      end

      context "mistakenly referencing unavailable variables" do
        let(:yaml_str) { "k1: <%=dne%>\n---\nk1: bar" }
        it "raises a normal NameError" do
          expect do
            subject.interpolate_erb_string(yaml_str)
          end.to raise_error(NameError)
        end
      end
    end

    context "passing a non-nil source binding" do
      let(:yaml_str) { "k1: \"<%=values[:k1]%>\"\n---\nk1: bar" }
      let(:exp_result) { "k1: \"baz\"\n---\nk1: bar" }
      it "uses the binding correctly" do
        result = subject.interpolate_erb_string(
          yaml_str,
          src_binding: TestObj.new.get_binding,
        )
        expect(result).to eq(exp_result)
      end
    end
  end

  describe ".yamls_in_dir_to_dicts" do

  end

  describe ".str_cmp" do
    context "when it should be true" do
      it "returns true" do
        expect(subject.str_cmp("Pod", "Pod")).to eq(true)
        expect(subject.str_cmp("Po.*", "Pod")).to eq(true)
      end
    end
    context "when it should be false" do
      it "returns false" do
        expect(subject.str_cmp("Pods", "Pod")).to eq(false)
        expect(subject.str_cmp("Po", "Pod")).to eq(false)
      end
    end

  end

  describe ".res_dict_matches_rule?" do
    let :res_dict do
      {kind: "Pod", metadata: {name: "foo"}}
    end

    context "when it should be true" do
      it "returns true" do
        func = -> (*args) { subject.res_dict_matches_rule?(*args) }
        expect(func[res_dict, {kind: "Pod"}]).to be_truthy
        expect(func[res_dict, {kind: "Po.*"}]).to be_truthy
        expect(func[res_dict, {kind: ".*"}]).to be_truthy

        expect(func[res_dict, {name: "foo"}]).to be_truthy
        expect(func[res_dict, {name: "fo[o|a]"}]).to be_truthy

        expect(func[res_dict, {kind: "Pod", name: ""}]).to be_truthy
        expect(func[res_dict, {kind: ".*", name: "foo"}]).to be_truthy
        expect(func[res_dict, {kind: "P.*", name: "fo[o|a]"}]).to be_truthy
      end
    end

    context "when it should be false" do
      it "returns false" do
        func = -> (*args) { subject.res_dict_matches_rule?(*args) }
        expect(func[res_dict, {kind: "Pods"}]).to be_falsey
        expect(func[res_dict, {kind: "Po"}]).to be_falsey
        expect(func[res_dict, {kind: "Pod", name: "bar"}]).to be_falsey
        expect(func[res_dict, {kind: ".*", name: "fo[b|a]"}]).to be_falsey
      end
    end
  end

  let :dirty_res_dicts do
    [
      {kind: "PersistentVolume", metadata: { name: "pv" }},
      {kind: "PersistentVolumeClaim", metadata: { name: "pvc" }},
      {kind: "Pod", metadata: { name: "pod" }}
    ].map(&:stringify_keys)
  end

  let(:clean_res_dicts) { dirty_res_dicts.map(&:deep_symbolize_keys) }
  let(:white_rules) { [{kind: "PersistentVolume.*"}] }
  let(:black_rules) { [{name: "pvc"}] }

  describe ".select_res_dicts_blacklist" do
    it "excludes the res dicts that match the rule" do
      result = subject.select_res_dicts_blacklist(dirty_res_dicts, black_rules)
      expect(result).to match_array([clean_res_dicts[0], clean_res_dicts[2]])
    end
  end

  describe ".select_res_dicts_blacklist" do
    it "excludes the res dicts that do not match the rule" do
      result = subject.select_res_dicts_whitelist(dirty_res_dicts, white_rules)
      expect(result).to eq(clean_res_dicts[0..1])
    end
  end

  describe ".clean_and_filter_hashes" do
    context "without any filtering" do
      it "returns the res_dicts unchanged and symbolized" do
        result = subject.clean_and_filter_dicts(dirty_res_dicts)
        expect(result).to eq(clean_res_dicts)
      end
    end

    context "with white and black rules" do
      it "returns the res_dicts filtered and symbolized" do
        result = subject.clean_and_filter_dicts(
          dirty_res_dicts,
          white_rules: white_rules,
          black_rules: black_rules
        )
        expect(result).to eq(clean_res_dicts[0..0])
      end
    end
  end
end
