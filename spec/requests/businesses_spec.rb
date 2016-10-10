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

RSpec.describe 'standard CRUD operations', type: :request do
	# Eventually replace explicit data with general junk data via FactoryGirl:
	# let(:data){ FactoryGirl.create(:business) }
	# let(:data){ FactoryGirl.create(:business) }
	let(:data){{
			uuid: 		SecureRandom.uuid,
			name: 'Gordian Information Farmers Exchange, LLC.',
			address: '5392 Main Street',
			address2: 'Building 2',
			city: 'Bismarck',
			state: 'North Dakota',
			zip: '42032',
			country: 'US',
			phone: '3852710573',
			website: 'http://www.gif-exchange.net'
		}}
 	let(:data2){{
			name: 'GIF Exchange, Inc.',
			address: '3020 Golden Crest Drive',
			address2: '',
			city: 'Bismarck',
			state: 'North Dakota',
			zip: '42030',
			country: 'US',
			phone: '3852710573',
			website: 'http://www.gif-ex.net'
  }}

  it 'does not create a new record without the token' do
		post '/businesses', data.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
		json = JSON.parse(response.body)
		expect(response).to have_http_status(401)
	end
  it 'does not create a new record with the wrong token' do
		post '/businesses', data.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=wrong'}
		json = JSON.parse(response.body)
		expect(response).to have_http_status(401)
	end

	it 'creates a new record with the correct token' do
		post '/businesses', data.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
		json = JSON.parse(response.body)
		expect(response).to be_success
	end

	it 'does not read the records without the token' do
    get "/businesses", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
		expect(response).to have_http_status(401)


    get "/businesses/1", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
		expect(response).to have_http_status(401)
	end

  it 'does not read the records with the wrong token' do
	  get "/businesses", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=wrong'}
		expect(response).to have_http_status(401)


    get "/businesses/1", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=wrong'}
		expect(response).to have_http_status(401)
	end

	it 'reads the records with the correct token' do
		get "/businesses", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
    json_all = JSON.parse(response.body)
    expect(response).to be_success

    business = json_all['businesses'][0]['id']

    get "/businesses/#{business}", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
    json_one = JSON.parse(response.body)
    expect(response).to be_success

    expect(json_one['name']).to eq('Gordian Information Farmers Exchange, LLC.')
	end

	it 'does not update the record without the token' do
    put "/businesses/1", data2.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
		expect(response).to have_http_status(401)
	end

	it 'does not update the record with the wrong token' do
    put "/businesses/1", data2.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=wrong'}
		expect(response).to have_http_status(401)
	end

	it 'updates the record with the correct token' do
		get '/businesses', {}, {'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
    json_all = JSON.parse(response.body)
    expect(response).to be_success

    business = json_all['businesses'][0]['id']

		put "/businesses/#{business}", data2.to_json, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
		json_one = JSON.parse(response.body)
		
		expect(response).to be_success
		expect(json_one['message']).to eq('Successfully updated business.')
		expect(json_one['business']['name']).to eq('GIF Exchange, Inc.')
		expect(json_one['business']['website']).to eq('http://www.gif-ex.net')
	end

	it 'does not destroy the record without the token' do
    delete "/businesses/1", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json'}
		expect(response).to have_http_status(401)
	end

	it 'does not destroy the record with the wrong token' do
    delete "/businesses/1", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=wrong'}
		expect(response).to have_http_status(401)
	end

  it 'destroys the record with the correct token' do
    get '/businesses', {}, {'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
    json_all = JSON.parse(response.body)
    expect(response).to be_success

    business = json_all['businesses'][0]['id']
    delete "/businesses/#{business}", {}, {'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}
    json_gone = JSON.parse(response.body)

    expect(response).to be_success
    expect(json_gone['message']).to eq("Successfully deleted business id #{business}.")
  end
end

RSpec.describe 'nonexistent api record', :type => :request do
  it 'returns 401 for a nonexistent record without a token' do
    get '/businesses/96524'
    expect(response).to have_http_status(401) # we don't even know it doesn't exist
  end

  it 'returns 401 for a nonexistent record with a bad token' do
    get '/businesses/96524', {}, {'HTTP_AUTHORIZATION' => 'Token token=wrong'}
    expect(response).to have_http_status(401) # we don't even know it doesn't exist
  end

  it 'gets a nonexistent record' do
    get '/businesses/96524', {}, {'HTTP_AUTHORIZATION' => 'Token token=abcde12345'}

    json = JSON.parse(response.body)

    expect(response).to have_http_status(404)
    expect(json['status']).to eq(404)
    expect(json['error']).to eq('Record not found')
  end
end
