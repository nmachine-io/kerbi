require_relative './../spec_helper'

RSpec.describe Kerbi::CodeGen::ProjectGenerator do

  let(:klass) { Kerbi::CodeGen::ProjectGenerator }
  let(:root) { Kerbi::Testing::TEST_YAMLS_DIR }
  let(:project_name) { "test-project" }
  let(:dir_path) { "#{root}/#{project_name}" }

  before :each do
    Kerbi::Testing.reset_test_yamls_dir
  end

  describe "#run" do
    let(:expected_files) { %w[Gemfile kerbifile.rb values.yaml] }
    it "creates a new dir and writes the files" do
      expect(File.exists?(dir_path)).to be_falsey
      generator = klass.new(project_name: project_name, root_dir: root)
      generator.run
      expect(File.exists?(dir_path)).to be_truthy
      actual = Dir.entries(dir_path)
      expect((expected_files - actual)).to be_empty
    end
  end
end