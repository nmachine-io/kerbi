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

    context "writing state" do

      before :each do
        kmd("create ns #{namespace}")
        kmd("delete cm #{cm_name} -n #{namespace}")
      end

      context "with a new tag" do
        before :each do
          backend = make_backend(namespace)
          backend.provision_missing_resources(quiet: true)
          expect(backend.read_write_ready?).to eq(true)
        end

        let(:expect_values) do
          { pod: { image: "cent_os" }, service: { type: "ClusterIP"} }
        end

        let(:expect_default_values) do
          { pod: { image: "nginx" }, service: { type: "ClusterIP"} }
        end

        it "creates a new entry with the expected values" do
          backend = make_backend(namespace)
          expect(backend.entries.any?).to be_falsey
          base_cmd = "template foo --set pod.image=cent_os --write-state foo"
          cmd = mk_cmd(base_cmd, namespace)

          expect_cli_eq_file(cmd, "root", "template-write", "yaml")

          backend = make_backend(namespace)
          entry = backend.entries[0]
          expect(backend.entries.count).to eq(1)

          expect(entry.tag).to eq("foo")
          expect(entry.values).to eq(expect_values)
          expect(entry.default_values).to eq(expect_default_values)
        end
      end

      context "with an existing tag" do

      end
    end

    context "reading state" do

    end

  end
end