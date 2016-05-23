# Running the App

# Importing Data

The application is designed to import data from a .csv file via the browser. In order to import a .csv, go to the root path `http://localhost:3000`, select your file, and click `Import`. Depending on the size of the CSV you are importing, the process can take several minutes.

The page will refresh once the import process is complete, notifying you once the import is successful:

![Success Colbert!](http://i.giphy.com/zaqclXyLz3Uoo.gif)

(Sorry, no glorious Colbert GIFs included in the app.)

## Data Restrictions

The DB schema is set to store all data values as strings. This is to preserve the integrity of certain values, particularly `zip` and `phone` values, which in some cases may begin with 0. Since the numbers in these fields are not being used to conduct mathematical operations, I decided to forego saving these values as integers.

### Additional Notes on Data Restrictions

1. The app is configured to validate all `uuid` values to be 36 characters in length. Any more or less will return a 422 status.
2. The `name`, `address`, `city`, `state`, and `country` are all validated by the app to be at least 2 characters in length.
3. The app validates the `zip` value to be at least 5 characters in length.
4. The app validates the `phone` value to be at least 10 characters in length.
5. The app validates the `website` value to be at least 7 characters in length (just enough for `http://`).
6. Any value length that does not meet the minimum requirements specified in 2-5 above will return a `HTTP 422 - unprocessable entity` status.
6. The only value that can be blank on creation or update is the `address2` value. If the value is blank, it will be saved to the database as `null`. This is the only allowable `null` value in the API.

# Authentication

Currently the API does not support authentication, making all records in the DB publicly accessible. This is likely to change in the future.

The app also skips verification of the Rails authenticity token, allowing for CRUD operations from external applications.

The authenticity token is NOT overlooked on CSV import. Any CSV import must be done from `http://localhost:3000/businesses/new` (which is also the app's root url).

# Endpoints

## Batches of Records

When accessing the API endpoint via a `GET` request to `http://localhost:3000/businesses`, the api will return a default batch of 50 records.

These defaults can be changed by use of a query string. In order to access a batch of records, add `http://localhost:3000/businesses?batch=X&page=Y`. X is the number of records you want to return while Y is the page you would like to start on.

Example: `http://localhost:3000/api/businesses?batch=100&page=3` will return 100 records starting at the 300th record.

### Notes on Retrieving Batches

The API does not support batches larger than 1000. Attempts to call batches larger than 1000 will return a 404. I've specifically added this limitation, modeling it on the Rails `.find_each` and `.find_in_batches` methods, which automatically set the retrieval limit to 1000. Thus, 1000 seemed to be an appropriate value, since it is consistent with default Active Record behavior in Rails.

This limit can easily be changed. On line 19 of `businesses_controller.rb`, change `limit = 1000` to `limit = your_limit_here`, where `your_limit_here` is the maximum number of records you want to retrieve at once.

**WARNING:** retrieving an ungodly number of records can crash the app. But you know that. Change the limit at your discretion.

![Homer is in over his head. Don't be Homer.](http://i.giphy.com/l2JdXsNTgXXHph4VW.gif)

## Specific Records

To retrieve a specific record, send a `GET` request to `http://localhost:3000/businesses/{:id}`, where `{:id}` is the database id of the record you wish to retrieve.

If the record does not exist, the API will return a 500 status with an error message of `Record not found.`

# Other CRUD Operations

Creating, updating, or destroying records can be done by sending an HTTP request with the appropriate verbs and data to the proper RESTful URL. Below are a few examples.

## Creating a New Record

In order to create a new record, send a POST request with JSON header information and data to the appropriate URL:

```
curl -i -H "Accept: application/json" -H "Content-type: application/json" -X POST -d "{\"uuid\":\"c5b83c2d-a6ef-4e22-9d0e-f53cecae4105\",\"name\":\"Waterfield and Sons, LLC\",\"address\":\"4231 Beverly Blvd\",\"address2\":\"Suite 400\",\"city\":\"Whittier\",\"state\":\"CA\",\"zip\":\"90601\",\"country\":\"US\",\"phone\":5625559182,\"website\":\"http://www.waterfield-and-sons.net\"}" http://localhost:3000/businesses
```

### Notes on Creating New Records

1. The app validates the presence of `uuid`,`name`, `address`, `city`, `state`, `zip`, `country`, `phone`, and `website` on creation. If any of these values are blank or the key-value pair is missing from the JSON data, the record will not be created.
2. The app validates the length of each value. See **Additional Notes on Data Restrictions** above for details on required value lengths.

## Updating an Existing Record

To update an existing record, send a PUT request with JSON header information containing only the data you want to update to the appropriate URL:

```
curl -i -H "Accept: application/json" -H "Content-type: application/json" -X PUT -d "{\"name\":\"Waterfield and Sons, Incorporated\",\"address\":\"2016 Valley View Ave\",\"address2\":\"\",\"city\":\"La Mirada\",\"state\":\"CA\",\"zip\":\"90604\"}" http://localhost:3000/api/businesses/{:id}
```

### Notes on Updating Records

1. Send ONLY the information you want to update. If you send a JSON key with an empty value, the API will return a `HTTP 422 - unprocessable entity` error along with a JSON response containing the list of errors, notifying you which fields cannot be blank.
2. You CAN send the `address2` field with an empty value. This will be saved to the database as a `NULL` field.
3. See **Additional Notes on Data Restrictions** above for details on required value lengths.

## Destroying an Existing Record

To destroy an existing record, send a DELETE request with JSON header information to the appropriate record URL:

```
curl -i -H "Accept: application/json" -H "Content-type: application/json" -X DELETE http://localhost:3000/businesses/{:id}
```

Because you're destroying a record, no validation takes place. It just gets nuked, like so:

![Nuke that record!](http://media3.giphy.com/media/9YtHBIlvnTqqQ/giphy.gif)

# Testing

Testing is done via rspec. All rspec dependencies should have been installed when you initially installed the application.

All tests are request tests, since the API is configured to 

Test coverage is included in 

Thanks for reading my documentation! Deadpool loves you for it:

![Much love from both of us.](http://images-cdn.moviepilot.com/images/c_scale,h_1080,w_1920/t_mp_quality/dxjmqifk5ub8okxkrnhq/james-gunn-explains-why-deadpool-made-so-much-money-844407.jpg)
