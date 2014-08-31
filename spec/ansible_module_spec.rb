require 'spec_helper'

require 'calc'

describe AnsibleModule do
  context 'Calc module' do
    context '.instance' do
      it 'should return a singleton instance of Calc class' do
        instance = Calc.instance
        expect(instance).to be_kind_of(Calc)
        expect(instance).to equal(Calc.instance)
      end
    end

    context 'Validation success' do
      let(:instance) { Calc.new(x: '100', y: '100') }
      before { allow(instance).to receive(:exit) }

      it 'should print result in the json form' do
        expect { instance.run }.to output(%r{"sum":200}).to_stdout
      end

      it 'should exit with 0' do
        allow(instance).to receive(:print)
        instance.run
        expect(instance).to have_received(:exit).with(0)
      end
    end

    context 'Validation failure' do
      let(:instance) { Calc.new(x: '', y: '100') }
      before { allow(instance).to receive(:exit) }

      it 'should print result in the json form' do
        expect { instance.run }.to output(%r{X can\'t be blank\.}).to_stdout
      end

      it 'should exit with 1' do
        allow(instance).to receive(:print)
        instance.run
        expect(instance).to have_received(:exit).with(1)
      end
    end
  end
end
