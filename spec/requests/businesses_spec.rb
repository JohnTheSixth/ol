require 'spec_helper'
require 'json'

# The following tests all run under two assumptions:
# (1) The rspec tests are running in the 'TEST' environment.
# (2) The existing test DB has no records.
# All records in the DB are dropped after these tests run.
# To change this behavior, comment out or delete lines 48-50 in spec_helper.rb:
# config.after :all do
#   ActiveRecord::Base.subclasses.each(&:delete_all)
# end

RSpec.describe 'standard CRUD operations', :type => :request do
	it 'creates a new record' do
		data = {
			uuid: SecureRandom.uuid,
			name: 'Gordian Information Farmers Exchange, LLC.',
			address: '5392 Main Street',
			address2: 'Building 2',
			city: 'Bismarck',
			state: 'North Dakota',
			zip: '42032',
			country: 'US',
			phone: '3852710573',
			website: 'http://www.gif-exchange.net'
		}

		post '/businesses', data.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}

		json = JSON.parse(response.body)

		expect(response).to be_success
	end

	it 'reads the records' do
		get '/businesses'
    json_all = JSON.parse(response.body)
    expect(response).to be_success

    business = json_all['businesses'][0]['id']

    get "/businesses/#{business}"
    json_one = JSON.parse(response.body)
    expect(response).to be_success

    expect(json_one['name']).to eq('Gordian Information Farmers Exchange, LLC.')
	end

	it 'updates the record' do
		get '/businesses'
    json_all = JSON.parse(response.body)
    expect(response).to be_success

    business = json_all['businesses'][0]['id']

		data = {
			name: 'GIF Exchange, Inc.',
			address: '3020 Golden Crest Drive',
			address2: '',
			city: 'Bismarck',
			state: 'North Dakota',
			zip: '42030',
			country: 'US',
			phone: '3852710573',
			website: 'http://www.gif-ex.net'
		}

		put "/businesses/#{business}", data.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}

		json_one = JSON.parse(response.body)
		
		expect(response).to be_success
		expect(json_one['message']).to eq('Successfully updated business.')
		expect(json_one['business']['name']).to eq('GIF Exchange, Inc.')
		expect(json_one['business']['website']).to eq('http://www.gif-ex.net')
	end

	it 'destroys the record' do
		get '/businesses'
    json_all = JSON.parse(response.body)
    expect(response).to be_success

    business = json_all['businesses'][0]['id']

    delete "/businesses/#{business}", {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}

    json_gone = JSON.parse(response.body)

    expect(response).to be_success
    expect(json_gone['message']).to eq("Successfully deleted business id #{business}.")
	end
end

RSpec.describe 'nonexistent api record', :type => :request do
  it 'gets a nonexistent record' do
    get '/businesses/96524'

    json = JSON.parse(response.body)

    expect(response).to have_http_status(404)
    expect(json['status']).to eq(404)
    expect(json['error']).to eq('Record not found')
  end
end