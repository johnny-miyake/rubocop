# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnifiedInteger, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'registers an offense' do |klass|
    context 'target ruby version < 2.4', :ruby23 do
      context "when #{klass}" do
        context 'without any decorations' do
          let(:source) { "1.is_a?(#{klass})" }

          it 'registers an offense' do
            inspect_source(source)
            expect(cop.offenses.size).to eq(1)
            expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
          end

          it 'does not autocorrect' do
            new_source = autocorrect_source(source)
            expect(new_source).to eq(source)
          end
        end

        context 'when explicitly specified as toplevel constant' do
          let(:source) { "1.is_a?(::#{klass})" }

          it 'registers an offense' do
            inspect_source(source)
            expect(cop.offenses.size).to eq(1)
            expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
          end

          it 'autocorrects' do
            new_source = autocorrect_source(source)
            expect(new_source).to eq(source)
          end
        end

        context 'with MyNamespace' do
          it 'does not register an offense' do
            expect_no_offenses("1.is_a?(MyNamespace::#{klass})")
          end
        end
      end
    end

    context 'target ruby version >= 2.4', :ruby24 do
      context "when #{klass}" do
        context 'without any decorations' do
          let(:source) { "1.is_a?(#{klass})" }

          it 'registers an offense' do
            inspect_source(source)
            expect(cop.offenses.size).to eq(1)
            expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
          end

          it 'autocorrects' do
            new_source = autocorrect_source(source)
            expect(new_source).to eq('1.is_a?(Integer)')
          end
        end

        context 'when explicitly specified as toplevel constant' do
          let(:source) { "1.is_a?(::#{klass})" }

          it 'registers an offense' do
            inspect_source(source)
            expect(cop.offenses.size).to eq(1)
            expect(cop.messages).to eq(["Use `Integer` instead of `#{klass}`."])
          end

          it 'autocorrects' do
            new_source = autocorrect_source(source)
            expect(new_source).to eq('1.is_a?(::Integer)')
          end
        end

        context 'with MyNamespace' do
          it 'does not register an offense' do
            expect_no_offenses("1.is_a?(MyNamespace::#{klass})")
          end
        end
      end
    end
  end

  include_examples 'registers an offense', 'Fixnum'
  include_examples 'registers an offense', 'Bignum'

  context 'when Integer' do
    context 'without any decorations' do
      it 'does not register an offense' do
        expect_no_offenses('1.is_a?(Integer)')
      end
    end

    context 'when explicitly specified as toplevel constant' do
      it 'does not register an offense' do
        expect_no_offenses('1.is_a?(::Integer)')
      end
    end

    context 'with MyNamespace' do
      it 'does not register an offense' do
        expect_no_offenses('1.is_a?(MyNamespace::Integer)')
      end
    end
  end
end
