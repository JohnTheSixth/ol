class ChangeColumnNull < ActiveRecord::Migration
  def change
  	change_column_null :businesses, :uuid, false
  	change_column_null :businesses, :name, false
  	change_column_null :businesses, :address, false
  	change_column_null :businesses, :city, false
  	change_column_null :businesses, :state, false
  	change_column_null :businesses, :zip, false
  	change_column_null :businesses, :country, false
  	change_column_null :businesses, :phone, false
  	change_column_null :businesses, :website, false
  end
end
