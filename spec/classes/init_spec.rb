require 'spec_helper'
describe 'hiera_jenkins' do

  context 'with defaults for all parameters' do
    it { should contain_class('hiera_jenkins') }
  end
end
