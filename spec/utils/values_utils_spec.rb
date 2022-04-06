require_relative './../spec_helper'

RSpec.describe Kerbi::Utils::Values do

  subject { Kerbi::Utils::Values }
  let(:root) { Kerbi::Testing::TEST_YAMLS_DIR }
  before(:each) { Kerbi::Testing.reset_test_yamls_dir }

  describe ".resolve_fname_expr (old)" do
    def func(fname)
      subject.resolve_fname_exprs([fname], root: root)
    end

    context "when the expression can be resolved" do
      context "when the filename is an exact match" do
        before :each do
          Kerbi::Testing.make_yaml("x", "n/a")
          Kerbi::Testing.make_yaml("x.yaml", "n/a")
          Kerbi::Testing.make_yaml("x.yaml.erb", "n/a")
        end
        it "returns that file instead over similar ones" do
          expect(func("x")).to eq(["#{root}/x"])
          expect(func("x.yaml")).to eq(["#{root}/x.yaml"])
          expect(func("x.yaml.erb")).to eq(["#{root}/x.yaml.erb"])
        end
      end

      context "when the filename is not an exact match" do
        before :each do
          Kerbi::Testing.make_yaml("y.yaml", "n/a")
          Kerbi::Testing.make_yaml("y.yaml.erb", "n/a")
        end

        it "returns the closes match" do
          expect(func("y")).to eq(["#{root}/y.yaml"])
          Kerbi::Testing.del_testfile("y.yaml")
          expect(func("y")).to eq(["#{root}/y.yaml.erb"])
        end
      end
    end

    context "when the expression cannot be resolved" do
      it "raises a Kerbi::ValuesFileNotFoundError with the right message" do
        cls = Kerbi::ValuesFileNotFoundError
        msg = "Could not resolve values file 'dne' in /tmp/kerbi-yamls"
        expect { func("dne") }.to raise_error(cls, msg)
      end
    end
  end

  describe ".resolve_fname_exprs" do

    def func(*args, **kwargs)
      subject.resolve_fname_exprs(*args, **kwargs, root: root)
    end

    before :each do
      Kerbi::Testing.make_yaml("x.yaml", "n/a")
      Kerbi::Testing.make_yaml("y.yaml", "n/a")
    end

    context "with no missing file other than 'values'" do
      it "returns the expect list of final paths" do
        expect(func(["x.yaml"])).to eq(["#{root}/x.yaml"])
        expect(func(%w[x.yaml x])).to eq(["#{root}/x.yaml"])
      end
    end

    context "with a missing file other than 'values'" do
      it "raises an exception" do
        expect{ func(["dne"]) }.to raise_exception(Exception)
      end
    end
  end

  describe ".parse_inline_assignment" do
    def func(expr)
      subject.parse_inline_assignment(expr)
    end

    context "a malformed expression" do
      it "raises an exception" do
        expect { func("foo=") }.to raise_error(Exception)
        expect { func("foo:bar") }.to raise_error(Exception)
        expect { func("=bar") }.to raise_error(Exception)
        expect { func("=") }.to raise_error(Exception)
        expect { func("none") }.to raise_error(Exception)
      end
    end

    context "a well formed expression" do
      it "outputs a symbol-keyed dict" do
        expect(func("foo=bar")).to eq({foo: "bar"})
        expect(func("foo.bar=baz")).to eq({foo: { bar: "baz" }})
      end
    end
  end

  describe ".from_inlines" do
    def func(*args, **kwargs)
      subject.from_inlines(*args, **kwargs)
    end

    it "parses and deep merges the expressions" do
      result = func(%w[foo=bar foo.bar=baz bar=foo])
      expect(result).to eq({foo: {bar: "baz"}, bar: "foo"})
    end
  end

  describe ".load_yaml_files" do

    def func(*args, **kwargs)
      subject.load_yaml_files(*args, **kwargs)
    end

    before :each do
      Kerbi::Testing.make_yaml("x.yaml", "x: y")
      Kerbi::Testing.make_yaml("y.yaml", "y: z")
    end

    it "loads and merges the values from the given files" do
      result = func(%W[#{root}/x.yaml #{root}/y.yaml])
      expect(result).to eq(x: 'y', y: 'z')
    end
  end

  describe ".load_yaml_file" do
    context "with a valid yaml ERB file" do
      let(:yaml_content) { "foo: <%=b64enc('foo') %>" }
      it "loads, interpolates, and outputs an array of dicts" do
        fname = Kerbi::Testing.make_yaml("x.yaml", yaml_content)
        expect(subject.load_yaml_file(fname)).to eq(foo: "Zm9v")
      end
    end
    context "with an invalid yaml ERB file" do
      let(:yaml_content) { "foo: <%=b64enc('foo') %>\n---\nfoo: bar" }
    end
  end
end