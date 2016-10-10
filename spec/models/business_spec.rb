require 'spec_helper'

RSpec.describe 'Business', type: :model do

	it "has a valid factory" do
		expect(FactoryGirl.create(:business)).to be_valid
	end

end