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

def cli(command)
  original_stdout = $stdout
  $stdout = StringIO.new
  command = command.split(" ") if command.is_a?(String)
  Kerbi::Cli::RootHandler.start(command)
  output = $stdout.string
  $stdout = original_stdout
  output
end

def file_exp(dir, file, ext)
  path = "#{__dir__}/expectations/#{dir}/#{file}.#{ext}"
  File.read(path)
end

def expect_cli_eq_file(cmd, dir, file, ext)
  result = cli(cmd)
  expected = file_exp(dir, file, ext)

  if ext == 'json'
    expect(JSON.parse(result)).to eq(JSON.parse(expected))
  elsif ext == 'yaml'
    expect(YAML.load_stream(result)).to eq(YAML.load_stream(expected))
  else
    neutered_result = result.gsub(/\s+/, "").gsub("\e", "\\e")
    neutered_expected = expected.gsub(/\s+/, "")
    expect(neutered_result).to eq(neutered_expected)
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

