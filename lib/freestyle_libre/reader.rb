module FreestyleLibre
  class Reader
    VENDOR_ID = 0x1a61
    PRODUCT_ID = 0x3650
    INIT_CMDS = [0x04, 0x05, 0x15, 0x1]

    # @param interface [Number] The interface number of the device; needed in case you have several readers connected
    def initialize(interface = nil)
      HIDAPI::SetupTaskHelper.new(VENDOR_ID, PRODUCT_ID, "abbott-freestyle-libre", interface).run
      @device = HIDAPI::open(VENDOR_ID, PRODUCT_ID, interface)

      INIT_CMDS.each{ |c| init_cmd(c) }
    end

    def close
      @device.close
    end

    private

    def init_cmd(value)
      data = Array.new(64, 0x00)
      data[1] = value
      @device.write data
      read
    end

    # reads until non-sync data is found
    def read
      @device.read.tap{|result| puts result.bytes.map{|b| b.to_s(16)}.join(',')}
    end
  end
end
