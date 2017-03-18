require "freestyle_libre"
require "byebug"

reader = FreestyleLibre::Reader.new
puts "serial: #{reader.serial}"
puts "date: #{reader.date}"
reader.close
