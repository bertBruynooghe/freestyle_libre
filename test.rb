require "hidapi"

HIDAPI::SetupTaskHelper.new(
  0x1a61,             # vendor_id
  0x3650,             # product_id
  "abbott-freestyle-libre", # simple_name
  0                   # interface
).run

my_dev = HIDAPI::open(0x1a61, 0x3650)
#handle = my_dev.send(:handle)
#puts my_dev.manufacturer

data = Array.new(64, 0x00)
data[0] = 0x0
data[1] = 0x04 #command type
data[2] = 0x00 # command_len

my_dev.write data
result = my_dev.read
puts result.bytes.map{|b| b.to_s(16)}.join(',')

data[1] = 0x05
my_dev.write data
result = my_dev.read
puts result.bytes.map{|b| b.to_s(16)}.join(',')

data[1] = 0x15
my_dev.write data
result = my_dev.read
puts result.bytes.map{|b| b.to_s(16)}.join(',')

data[1] = 0x01
my_dev.write data
result = my_dev.read
puts result.bytes.map{|b| b.to_s(16)}.join(',')

my_dev.close

# current status: initialization sequence seems to be behaving as expected.
