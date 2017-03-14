require "hidapi"

HIDAPI::SetupTaskHelper.new(
  0x1a61,             # vendor_id
  0x3650,             # product_id
  "abbott-freestyle-libre", # simple_name
  0                   # interface
).run

my_dev = HIDAPI::open(0x1a61, 0x3650)
puts my_dev.manufacturer
my_dev.close
