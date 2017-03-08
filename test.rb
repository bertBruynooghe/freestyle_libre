require 'libusb'

usb = LIBUSB::Context.new
puts usb.devices(idVendor: 0x1a61, idProduct: 0x3650)

# device.open_interface(0) do |handle|
#   handle.control_transfer(bmRequestType: 0x40, bRequest: 0xa0, wValue: 0xe600, wIndex: 0x0000, dataOut: 1.chr)
# end
