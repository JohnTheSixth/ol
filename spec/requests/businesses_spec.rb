require 'spec_helper'
require 'json'

RSpec.describe 'default api listing', :type => :request do
  it 'gets the default listing' do
    get '/businesses'

    json = JSON.parse(response.body)

    expect(response).to be_success
    expect(json['businesses'].length).to eq(50)
  end
end

RSpec.describe 'custom api listing', :type => :request do
  it 'gets a custom listing' do
    get '/businesses?batch=100&page=2'

    json = JSON.parse(response.body)

    expect(response).to be_success
    expect(json['businesses'].length).to eq(100)
  end
end

RSpec.describe 'nonexistent api record', :type => :request do
  it 'gets a nonexistent record' do
    get '/businesses/96524'

    json = JSON.parse(response.body)

    expect(response).to have_http_status(404)
    expect(json['status']).to eq(404)
  end
end

RSpec.describe 'individual api record', :type => :request do
  it 'gets a single record' do
    get '/businesses/22959'

    json = JSON.parse(response.body)

    expect(response).to be_success
    expect(json['id']).to eq(22959)
  end
end