require_relative './../spec_helper'
require 'io/console'

RSpec.describe "$ kerbi [COMMAND]" do
  let(:namespace) { "kerbi-spec" }
  let(:cm_name) { Kerbi::State::Consts::RESOURCE_NAME }
  let(:exps_dir) { "root" }
  let(:root_dir) { "#{__dir__}/../../examples/hello-kerbi" }

  def mk_cmd(cmd, namespace=nil)
    target = "#{__dir__}/../../examples/hello-kerbi"
    cmd = "#{cmd} --project-root #{target}"
    cmd = "#{cmd} --namespace #{namespace}" if namespace
    cmd
  end

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
            cmd = mk_cmd("template foo #{bundle[0]}")
            expect_cli_eq_file(cmd, "root", bundle[1], "yaml")
          end
        end
      end
    end

    context "with --write-state and --read-state" do
      before :each do
        kmd("create ns #{namespace}")
        kmd("delete cm #{cm_name} -n #{namespace}")
      end

      let(:expect_values) do
        { pod: { image: "centos" }, service: { type: "ClusterIP"} }
      end

      let(:expect_default_values) do
        { pod: { image: "nginx" }, service: { type: "ClusterIP"} }
      end

      before :each do
        backend = make_backend(namespace)
        backend.provision_missing_resources(quiet: true)
        expect(backend.read_write_ready?).to eq(true)
      end

      def backend
        make_backend(namespace)
      end

      def mk_new_cmd(pod_image)
        base_cmd = "template foo --set pod.image=#{pod_image} --write-state foo"
        mk_cmd(base_cmd, namespace)
      end

      context "--write-state when the entry does not yet exist" do
        it "creates a new entry with the expected values" do
          expect(backend.entries.any?).to be_falsey
          expect_cli_eq_file(mk_new_cmd("centos"), "root", "template-write", "yaml")
          entry = backend.entries[0]
          expect(backend.entries.count).to eq(1)
          expect(entry.tag).to eq("foo")
          expect(entry.values).to eq(expect_values)
          expect(entry.default_values).to eq(expect_default_values)
        end
      end

      context "--write-state with an existing state entry" do
        let(:expect_values) do
          { pod: { image: "debian" }, service: { type: "ClusterIP"} }
        end
        it "updates the existing entry with the expected values" do
          expect(backend.entries.any?).to be_falsey
          expect_cli_eq_file(mk_new_cmd("centos"), "root", "template-write", "yaml")
          cli(mk_new_cmd("debian"))
          entry = backend.entries[0]
          expect(backend.entries.count).to eq(1)
          expect(entry.tag).to eq("foo")
          expect(entry.values).to eq(expect_values)
          expect(entry.default_values).to eq(expect_default_values)
        end
      end

      context "--read-state with an existing state entry" do
        context "without inline overrides" do
          it "echos the expected text" do
            expect(backend.entries.any?).to be_falsey
            expect_cli_eq_file(mk_new_cmd("centos"), "root", "template-write", "yaml")
            cmd = mk_cmd("template foo --read-state foo", namespace)
            expect_cli_eq_file(cmd, "root", "template-read", "yaml")
          end
        end

        context "with inline overrides" do
          it "echos the expected text, preferring the inline over the state" do
            expect(backend.entries.any?).to be_falsey
            expect_cli_eq_file(mk_new_cmd("centos"), "root", "template-write", "yaml")
            cmd = mk_cmd("template foo --read-state foo --set pod.image=busybox", namespace)
            expect_cli_eq_file(cmd, "root", "template-read-inlines", "yaml")
          end
        end
      end
    end
  end
end