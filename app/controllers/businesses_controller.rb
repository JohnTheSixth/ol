class BusinessesController < ApplicationController

  # Skipping authenticity so the API can be accessed by external applications.
  # Importing a CSV still requires the authenticity token and can only be done in-app.
  before_filter :restrict_access
  skip_before_filter :verify_authenticity_token, except: [:import]

  def index
    batch = if params[:batch] && params[:batch].length > 0
              params[:batch].to_f
            else
              50
            end
    page  = if params[:page] && params[:page].length > 0
              params[:page].to_f
            else
              1
            end
    start = batch * (page - 1)
    limit = 1000

    if batch > limit
      render status: 422, json: {
        status: 422,
        error: "Cannot retrieve more than #{limit} records at a time."
      }
    else
      businesses = Business.order(id: :asc).limit(batch).offset(start)

      if businesses.length == 0
        render status: 404, json: {
          status: 404,
          error: 'No records found.'
        }
      else
        render status: 200, json: {
          max_records_per_page: batch,
          page: page,
          total_records_returned: businesses.length,
          businesses: businesses
        }
      end
    end
  end

  def show
    business = Business.find(params[:id])
    render status: 200, json: business
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: {
      status: 404,
      error: 'Record not found'
    }
  end

  def new
  end

  def create
    business = Business.new(business_params)

    if business.save
      render status: 200, json: business
    else
      render status: 422, json: {
        status: 422,
        errors: business.errors
      }
    end
  end

  def update
    business = Business.find(params[:id])

    if business.update(business_params)
      render status: 200, json: {
        message: "Successfully updated business.",
        business: business
      }
    else
      render status: 422, json: {
        status: 422,
        errors: business.errors
      }
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: {
      status: 404,
      error: 'Record not found'
    }
  end

  def destroy
    business = Business.find(params[:id])

    business.destroy
    render status: 200, json: {
      message: "Successfully deleted business id #{business.id}."
    }
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: {
      status: 404,
      error: 'Record not found'
    }
  end

  def import
    if params[:file]
      Business.import(params[:file])
      redirect_to root_path, notice: '.csv successfully imported.'
    else
      redirect_to root_path, notice: 'Please choose a .csv file to import.'
    end
  end

private

  def business_params
    params.require(:business).permit(:uuid, :name, :address, :address2, :city, :state, :zip, :country, :phone, :website, :created_at)
  end

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      if token != 'abcde12345'
        render status: 401, json: {
          status: 401,
          message: 'Unauthorized Access'
        } and return
      end
    end
  end

end