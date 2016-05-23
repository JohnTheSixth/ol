class Business < ActiveRecord::Base

	# Consistent with the database, only 'address2' is allowed to be null.
	# All other fields must have a value on creation.
	validates_presence_of :uuid, :name, :address, :city, :state, :zip, :country, :phone, :website, :on => :create
	
	# Ensures any submitted UUID (on create or on update) is unique
	validates_uniqueness_of :uuid
	
	# Ensures UUID length is exactly 36.
	validates_length_of :uuid, is: 36, allow_blank: false
	
	# Since most of the values below can vary widely, the minimum character length is 2.
	validates_length_of :name, minimum: 2, allow_blank: false
	validates_length_of :address, minimum: 2, allow_blank: false
	validates_length_of :city, minimum: 2, allow_blank: false
	validates_length_of :state, minimum: 2, allow_blank: false
	validates_length_of :country, minimum: 2, allow_blank: false
	
	# Validates character length for at least a 5-digit postal code.
	validates_length_of :zip, minimum: 5, allow_blank: false

	# Validates character length to account for area+3+4.
	validates_length_of :phone, minimum: 10, allow_blank: false
	
	# Validates minimum presence of 'http://'
	validates_length_of :website, minimum: 7, allow_blank: false

	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			# If the UUID exists in the database, it will assign the record to the variable.
			business = find_by_uuid(row['uuid']) || new

			# Only creates a new record. Will not update existing records.
			if business[:uuid] == nil
				business.attributes = row.to_hash
				business.save!
			end
		end
	end

end