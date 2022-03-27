require 'tempfile'
require 'simplecov'

SimpleCov.start

require_relative './../lib/kerbi'

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

