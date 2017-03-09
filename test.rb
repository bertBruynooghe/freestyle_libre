require 'hid_api'

device = HidApi.open(0x1a61, 0x3650)
puts device.product_string
puts device.manufacturer_string
device.close
