The idea of this project is to be able to read relevant data from the Abbott FreeStyle Libre through USB.


In first instance, this will stay nothing more than a simple ruby snippet which outputs some of the data.

As for now, I will limit myself to macOS, although it should work as-is on Windows and Linux too.

Planned spin-offs of this project are:

* a tool that directly uploads meter values to NightScout
* a 'library' for arduino to get access to the meter values.

Based on the splendid work of https://github.com/Flameeyes/glucometer-protocols

** Testing

* make sure you have a reader with at least some valid readings
* create a .env file with `SERIAL` and `SWVER` (if you don't, the tests will fail and you read the values form the test results)
* export data of your reader to `libre.export` and put the file in the root of the project
* connect your reader
* `bundle exec rspec`
