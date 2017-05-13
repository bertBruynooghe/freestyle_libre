# FreestyleLibre

This is a gem the allows accessing Abbott's FreeStyle Libre data,
both over USB and from the export file from the official Abbott application.

It is based both on the splendid work of https://github.com/Flameeyes/glucometer-protocols, and https://github.com/barkerest/hidapi

Implementation is not fully complete, but it already supports all glucose measurements, both manual and automatic.

Documentation is following.

## Testing

* make sure you have a reader with at least some valid readings
* create a .env file with `SERIAL` and `SWVER` (if you don't, the tests will fail and you read the values form the test results)
* export data of your reader to `libre.export` and put the file in the root of the project
* connect your reader
* `bundle exec rspec`
