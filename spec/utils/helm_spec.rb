require_relative './../spec_helper'

RSpec.describe Kerbi::Utils::Helm do

  subject { Kerbi::Utils::Helm }

  def find_res(hashes, kind, name)
    hashes.find do |hash|
      hash['kind'] == kind && hash['metadata']['name'] == name
    end
  end

  let :config do
    Kerbi::ConfigFile::Manager
  end

  before(:each) do
    # config.helm_exec = 'helm'
  end

  describe '.template' do
    let(:repo_org) { "jetstack" }
    let(:repo_url) { "https://charts.jetstack.io" }
    let(:chart) { "#{repo_org}/cert-manager" }
    let :values do
      {
        cainjector: {
          serviceAccount: {
            automountServiceAccountToken: "foo"
          }
        }
      }
    end

    before :each do
      system("helm repo add #{repo_org} #{repo_url}")
    end

    context 'with existing chart' do
      it 'returns the templated yaml string' do
        res_dicts = subject.template('kerbi', chart, values: values)
        expect(res_dicts.class).to eq(Array)
        expect(res_dicts.count).to be_within(40).of(40)
      end
    end

    it 'cleans up' do
      subject.template('kerbi', chart)
      expect(File.exists?(config.tmp_helm_values_path)).to be_falsey
    end
  end

  describe '.encode_inline_assigns' do
    context 'when assignments are flat' do
      it 'returns the right string' do
        #noinspection SpellCheckingInspection
        actual = subject.encode_inline_assigns(
          'bar': 'bar',
          'foo.bar': 'foo.bar'
        )
        expected = "--set bar=bar --set foo.bar=foo.bar"
        expect(actual).to eq(expected)
      end
    end

    context 'when values are nested' do
      it 'raises an runtime error' do
        expect do
          subject.encode_inline_assigns('bar': { foo: 'bar'})
        end.to raise_error("Assignments must be flat")
      end
    end
  end

  describe ".make_tmp_values_file" do
    it 'creates the tmp file with yaml and returns the path' do
      path = subject.make_tmp_values_file(foo: 'bar')
      expect(YAML.load_file(path)).to eq('foo' => 'bar')
    end
  end

  describe '.del_tmp_values_file' do
    context 'when the file exists' do
      it 'delete the file' do
        path = subject.make_tmp_values_file(foo: 'bar')
        expect(File.exists?(path)).to be_truthy
        subject.del_tmp_values_file
        expect(File.exists?(path)).to be_falsey
      end
    end

    context 'when the file does not exist' do
      it 'does not raise an error' do
        subject.del_tmp_values_file
      end
    end
  end

  describe '#can_exec?' do
    context 'exec working' do
      it 'returns true' do
        config.helm_exec = 'helm'
        expect(subject.can_exec?).to eq(true)
      end
    end

    context '.exec not working' do
      it 'returns false' do
        config.helm_exec = 'not-helm'
        expect(subject.can_exec?).to eq(false)
      end
    end
  end
end
