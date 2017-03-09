Trying to get usb started, but couldn't get the ruby-usb gem installed. (Same as (https://www.thekua.com/atwork/2012/05/usb-programming-with-ruby/) encountered?)
So I went fot ruby-usb instead.

After that, on OSX, I wasn't able to run this code due to `LIBUSB::ERROR_ACCESS in libusb_claim_interface` (https://github.com/tessel/node-usb/issues/30#issuecomment-244477201)

So I went looking for a way to access the hid_api gem instead:
(https://github.com/barkerest/hidapi), but also that didn't support Mac (https://github.com/barkerest/hidapi/issues/3)

So now off to [ruby-hid](https://github.com/gareth/ruby_hid_api) and see what happens there...  

(Might want to feel the need to do it through [FFI](https://spin.atomicobject.com/2014/01/31/ruby-prototyping-ffi/) instead, or even directly in C, but let's see how far I get...)
