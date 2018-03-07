# See spec/models/concerns/shared/ for functional tests on a fake Model, this only tests for include
shared_examples 'notable' do
  specify 'class includes Shared::Notes' do
    expect(described_class.ancestors.map(&:name).include?('Shared::Notes')).to be true
  end
end



