Trying to get usb started, but couldn't get the ruby-usb gem installed. (Same as (https://www.thekua.com/atwork/2012/05/usb-programming-with-ruby/) encountered?)
So I went for ruby-usb instead.

After that, on OSX, I wasn't able to run this code due to `LIBUSB::ERROR_ACCESS in libusb_claim_interface` (https://github.com/tessel/node-usb/issues/30#issuecomment-244477201)

So I went looking for a way to access the hid_api gem instead:
(https://github.com/barkerest/hidapi), <strike>but also that didn't support Mac</strike>
 (https://github.com/barkerest/hidapi/issues/3)

Tried [ruby-hid](https://github.com/gareth/ruby_hid_api) and see what happened there:
I could open and close the device at least, but no real communication with the device yet.
Documentation here is non-existent, and my skills lack to get this working...  

So went to [FFI](https://spin.atomicobject.com/2014/01/31/ruby-prototyping-ffi/) instead (maybe later directly in C, but let's see how far I get...).

In fact, to go on I should further experiment with the code and capture the output in wiredshark. However, to do that, I have to start working in Ubuntu...
