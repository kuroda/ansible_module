require 'spec_helper'

require 'calc'

describe AnsibleModule do
  context 'Calc module' do
    before do
      Calc.instance_variable_set(:@instance, nil)
      Calc.instance_variable_set(:@params, nil)
    end

    describe '.instance' do
      it 'should return a singleton instance of Calc class' do
        instance = Calc.instance
        expect(instance).to be_kind_of(Calc)
        expect(instance).to equal(Calc.instance)
      end
    end

    describe '.params' do
      it 'should return a hash constructed from a temp file' do
        fh = double('File Handler', read: 'x=100 y=50')
        allow(File).to receive(:open).and_yield(fh)

        p = Calc.params

        expect(p).to be_kind_of(Hash)
        expect(p[:x]).to eq('100')
        expect(p[:y]).to eq('50')
      end
    end

    context 'Validation success' do
      let(:instance) { Calc.new(x: '100', y: '50') }
      before { allow(instance).to receive(:print) }
      before { allow(instance).to receive(:exit) }

      it 'should print sum in JSON format' do
        instance.run
        expect(instance).to have_received(:print).with(%r{"sum":150})
        expect(instance).to have_received(:print).with(%r{"changed":true})
      end

      it 'should exit with 0' do
        instance.run
        expect(instance).to have_received(:exit).with(0)
      end
    end

    context 'Validation failure' do
      let(:instance) { Calc.new(x: '', y: '50') }
      before { allow(instance).to receive(:print) }
      before { allow(instance).to receive(:exit) }

      it 'should print validation error message in JSON format' do
        instance.run
        expect(instance).to have_received(:print).with(%r{X can\'t be blank\.})
        expect(instance).to have_received(:print).with(%r{"failed":true})
      end

      it 'should exit with 1' do
        instance.run
        expect(instance).to have_received(:exit).with(1)
      end
    end
  end
end
