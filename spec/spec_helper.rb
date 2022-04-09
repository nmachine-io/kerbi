require 'tempfile'
require 'simplecov'

SimpleCov.start

require_relative './../lib/kerbi'

def kmd(command)
  opts = { err: File::NULL, out: File::NULL }
  system("kubectl #{command} --context kind-kind", **opts)
end

# @return [Kerbi::State::ConfigMapBackend]
def make_backend(namespace)
  Kerbi::State::ConfigMapBackend.new(
    Kerbi::Utils::K8sAuth.kube_config_bundle,
    namespace
  )
end

def new_state(tag, dict={})
  set = dict.delete(:state)
  dict[:tag] = tag
  Kerbi::State::Entry.from_dict(set, dict)
end

def new_state_set(bundles)
  dicts = bundles.map { |kv| { tag: kv[0].to_s, **kv[1] } }
  Kerbi::State::EntrySet.new(dicts)
end

def cli(command, escaped: false)
  $stdout = StringIO.new
  begin
    command = command.split(" ") if command.is_a?(String)
    Kerbi::Cli::RootHandler.start(command)
    output = $stdout.string
    $stdout = STDOUT
    escaped ? output.gsub("\e", "\\e") : output
  ensure
    $stdout = STDOUT
  end
end

def load_exp_file(dir, file, ext)
  path = "#{__dir__}/expectations/#{dir}/#{file}.#{ext}"
  File.read(path)
end

def read_exp_file(dir, file, ext)
  expected_str = load_exp_file(dir, file, ext)
  if ext == 'json'
    JSON.parse(expected_str)
  elsif ext == 'yaml'
    YAML.load_stream(expected_str)
  else
    expected_str.gsub(/\s+/, "")
  end
end

def expect_cli_eq_file(cmd, dir, file, ext='txt')
  actual_str = cli(cmd)
  expected = read_exp_file(dir, file, ext)

  if ext == 'json'
    expect(JSON.parse(actual_str)).to eq(expected)
  elsif ext == 'yaml'
    actual = YAML.load_stream(actual_str)
    expect(actual).to eq(expected)
  else
    actual = actual_str.gsub(/\s+/, "").gsub("\e", "\\e")
    expect(actual).to eq(expected)
  end
end

def hello_kerbi(cmd, namespace=nil)
  target = "#{__dir__}/../examples/hello-kerbi"
  cmd = "#{cmd} --project-root #{target}"
  cmd = "#{cmd} --namespace #{namespace}" if namespace
  cmd
end

def cmd_group_spec(cmd, dir, file, opts={})
  (opts[:formats] || %w[yaml json table]).each do |format|
    context "with --output-format #{format} #{opts[:context_append]}" do
      it "echos the expected text" do
        extension = format == 'table' ? "txt" :  format
        cmd_with_fmt = "#{cmd} -o #{format}"
        expect_cli_eq_file(cmd_with_fmt, dir, file, extension)
      end
    end
  end
end

module Kerbi
  module Testing

    TEST_YAMLS_DIR = '/tmp/kerbi-yamls'

    def self.make_yaml(fname, contents)
      File.open(full_name = self.f_fname(fname), "w") do |f|
        contents = YAML.dump(contents) if contents.is_a?(Hash)
        f.write(contents)
      end
      full_name
    end

    def self.del_testfile(fname)
      full_name = self.f_fname(fname)
      if File.exists?(full_name)
        File.delete(full_name)
      end
    end

    def self.f_fname(fname)
      "#{TEST_YAMLS_DIR}/#{fname}"
    end

    def self.reset_test_yamls_dir
      system "rm -rf #{TEST_YAMLS_DIR}"
      system "mkdir #{TEST_YAMLS_DIR}"
    end
  end
end

