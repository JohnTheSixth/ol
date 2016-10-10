require 'faker'

FactoryGirl.define do
  factory :business do |f|
    f.uuid			{ SecureRandom.uuid }
    f.name			{ Faker::Company.name }
    f.address 	{ Faker::Address.street_address }
    f.address2	{ Faker::Address.secondary_address }
    f.city			{ Faker::Address.city }
    f.state			{ Faker::Address.state_abbr }
    f.zip 			{ Faker::Address.zip }
    f.country		{ Faker::Address.country }
    f.phone			{ Faker::PhoneNumber.subscriber_number(10) }
    f.website		{ Faker::Internet.url }
  end
end