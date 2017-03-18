module FreestyleLibre
  class Reader
    VENDOR_ID = 0x1a61
    PRODUCT_ID = 0x3650
    INIT_COMMAND_SEQUENCE = [0x04, 0x05, 0x15, 0x1]

    # @param interface [Number] The interface number of the device; needed in case you have several readers connected
    def initialize(interface = nil)
      HIDAPI::SetupTaskHelper.new(VENDOR_ID, PRODUCT_ID, "abbott-freestyle-libre", interface).run
      @device = HIDAPI::open(VENDOR_ID, PRODUCT_ID, interface)
      raise 'device cild not be opened' unless @device

      INIT_COMMAND_SEQUENCE.each do |c|
        write Report.new(command: c, payload: [])
        puts read
      end
    end

    def serial
      write Report.new(command: 0x60, payload: '$sn?'.bytes)
      read.payload.pack('C*').split("\r").first
    end

    def date
      write Report.new(command: 0x60, payload: '$date?'.bytes)
      month, day, year = *read.payload.pack('C*').split("\r").first.split(',').map(&:to_i)
      Date.new(year + 2000, month, day)
    end

    def close
      @device.close
    end

    private

    # @param report [#data] the report to be written
    def write(report)
      @device.write report.data
    end

    # reads until non-sync data is found
    def read
      Report.new(@device.read)
    end
  end
end
