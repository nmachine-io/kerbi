require 'tempfile'
require 'simplecov'

SimpleCov.start

require_relative './../lib/kerbi'

def new_state(tag, dict={})
  set = dict.delete(:state)
  dict[:tag] = tag
  Kerbi::State::Entry.from_dict(set, dict)
end

def new_state_set(bundles)
  dicts = bundles.map { |kv| { tag: kv[0].to_s, **kv[1] } }
  Kerbi::State::EntrySet.new(dicts)
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

