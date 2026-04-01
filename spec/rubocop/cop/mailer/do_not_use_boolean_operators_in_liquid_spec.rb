# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Mailer::UseBooleanWords, :config do
  subject(:cop) { described_class.new }

  let(:liquid_path) { 'app/views/mailer/template.liquid' }

  it 'registers offense for || in .liquid files and autocorrects to or' do
    source = "foo || bar"

    inspect_source(cop, source, liquid_path)

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq("Use 'or' instead of '||'.")

    corrected = autocorrect_source(source, filename: liquid_path)
    expect(corrected).to eq('foo or bar')
  end

  it 'registers offense for && in .liquid files and autocorrects to and' do
    source = "a && b"

    inspect_source(cop, source, liquid_path)

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq("Use 'and' instead of '&&'.")

    corrected = autocorrect_source(source, filename: liquid_path)
    expect(corrected).to eq('a and b')
  end

  it 'does not register offense in non-.liquid files' do
    inspect_source(cop, "foo || bar", 'app/models/user.rb')

    expect(cop.offenses).to be_empty
  end
end
