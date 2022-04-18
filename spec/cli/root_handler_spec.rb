require_relative './../spec_helper'
require 'io/console'

RSpec.describe "$ kerbi [COMMAND]" do
  let(:namespace) { "kerbi-spec" }
  let(:release_name) { "kerbi-spec" }
  let(:exps_dir) { "root" }
  let(:root_dir) { "#{__dir__}/../../examples/hello-kerbi" }

  spec_bundles = [
    ["", "template"],
    ["-f production", "template-production"],
    ["-f production --set pod.image=ubuntu", "template-inlines"]
  ].freeze

  describe "$ kerbi template" do

    context "without state" do
      spec_bundles.each do |bundle|
        context "with #{bundle[0].presence || "no args"}" do
          it "echos the expected text" do
            cmd = hello_kerbi("template foo . #{bundle[0]}")
            exp_cli_eq_file(cmd, "root", bundle[1], "yaml")
          end
        end
      end
    end

    context "with state" do

      let(:backend){ make_backend(release_name, namespace) }

      before :each do
        create_ns(namespace)
        delete_cm(backend.resource_name, namespace)
        backend.provision_missing_resources(quiet: true)
      end

      def exp_vals(which)
        str_keyed_hash = read_exp_file("root", "values", "json")
        str_keyed_hash.deep_symbolize_keys[which.to_sym]
      end

      def template_write_cmd(pod_image)
        base_cmd = "template #{release_name} . " \
                    "--set pod.image=#{pod_image}" \
                    " --write-state foo"
        hello_kerbi(base_cmd)
      end

      context "with writing" do
        before :each do
          cmd = template_write_cmd("centos")
          exp_cli_eq_file(cmd, "root", "template-write", "yaml")
        end

        context "--write-state when the entry does not yet exist" do
          it "creates a new entry with the expected values" do
            entry = backend.entries[0]
            expect(backend.entries.count).to eq(1)
            expect(entry.tag).to eq("foo")
            expect(entry.values).to eq(exp_vals("centos"))
            expect(entry.default_values).to eq(exp_vals("nginx"))
          end
        end

        context "--write-state with an existing state entry" do
          it "updates the existing entry with the expected values" do
            cli(template_write_cmd("centos"))
            cli(template_write_cmd("debian"))
            expect(backend.entries.count).to eq(1)
            entry = backend.entries[0]
            expect(entry.tag).to eq("foo")
            expect(entry.values).to eq(exp_vals("debian"))
            expect(entry.default_values).to eq(exp_vals("nginx"))
          end
        end
      end

      context "--read-state with an existing state entry" do
        before(:each) { cli(template_write_cmd("centos")) }

        context "without inline overrides" do
          it "echos the expected text" do
            base = "template #{release_name} . --read-state foo"
            cmd = hello_kerbi(base)
            exp_cli_eq_file(cmd, "root", "template-read", "yaml")
          end
        end

        context "with inline overrides" do
          it "echos the expected text, preferring the inline over the state" do
            base = "template #{release_name} . " \
                    "--read-state foo " \
                    "--set pod.image=busybox"
            cmd = hello_kerbi(base)
            exp_cli_eq_file(cmd, "root", "template-read-inlines", "yaml")
          end
        end
      end
    end
  end
end