require 'ostruct'
module FreestyleLibre
  class Reader
    VENDOR_ID = 0x1a61
    PRODUCT_ID = 0x3650
    INIT_COMMAND_SEQUENCE = [0x04, 0x05, 0x15, 0x1]

    # @param interface [Number] The interface number of the device; needed in case you have several readers connected
    def initialize(interface = nil)
      HIDAPI::SetupTaskHelper.new(VENDOR_ID, PRODUCT_ID, "abbott-freestyle-libre", interface).run
      @device = HIDAPI::open(VENDOR_ID, PRODUCT_ID, interface)
      raise 'device could not be opened' unless @device

      INIT_COMMAND_SEQUENCE.each do |c|
        write_report(c, '')
        read_report
      end
    end

    def serial
      write_report(0x60, '$sn?')
      read_text_command.strip
    end

    def software_version
      write_report(0x60, '$swver?')
      read_text_command.strip
    end

    def date_time
      write_report(0x60, '$date?')
      date = read_text_command.strip
      write_report(0x60, '$time?')
      DateTime.strptime("#{date} #{read_text_command}", '%m,%d,%y %H,%M')
    end

    def date_time=(value)
      write_report(0x60, "$date,#{value.strftime('%-m,%-d,%y')}")
      read_text_command
      write_report(0x60, "$time,#{value.strftime('%H,%M')}")
      read_text_command
    end

    def patient_name=(value)
      write_report(0x60, "$ptname,#{value}")
      read_text_command
    end

    def patient_name
      write_report(0x60, '$ptname?')
      read_text_command.strip
    end

    def patient_id=(value)
      write_report(0x60, "$ptid,#{value}")
      read_text_command
    end

    def patient_id
      write_report(0x60, '$ptid?')
      read_text_command.strip
    end

    # latest record ID ???
    def database_record_number
      # TODO: not sure this matches the description.
      # We should check that by scanning the tag two times and seeing that the number of new history
      # matches the increase of this number
      write_report(0x60, '$dbrnum?')
      read_text_command.gsub('DB Record Number =', '').strip.to_i
    end

    # Automatic glucose measurements
    def history
      write_report(0x60, '$history?')
      read_multi.map { |record| auto_measurement(record) }
    end

    # Manual measurements and date/time changes
    # @return [Record]
    def arresult
      write_report(0x60, '$arresult?')
      read_multi.map { |record| ar(record) }.compact
    end

    def close
      @device.close
    end

    private

    def ar(record)
      fields = record.split(',').map(&:strip)
      case fields[1]
      when "2"
        manual_measurement(fields)
      end
    end

    def manual_measurement(fields)
      Record.new(id: fields[0].to_i,
                     type: fields[1],
                     date_time: parse_date_time(fields[2...7]),
                     value: fields[12].to_i,
                     errored: fields[28].nil? || (fields[28].to_i & 0x8000) > 0,
                     error_code: fields[28])
    end

    def auto_measurement(record)
      fields = record.split(',').map(&:strip)
      Record.new(id: fields[0].to_i,
               date_time: parse_date_time(fields[2...7]),
               first_sensor_reading: fields[12]== "1",
               value: fields[13].to_i,
               sensor_runtime_minutes: fields[14].to_i,
               errored: fields[15].nil? || (fields[15].to_i & 0x8000) > 0,
               error_code: fields[15])
    end

    def parse_date_time(fields)
      DateTime.new(fields[2].to_i + 2000, fields[0].to_i, fields[1].to_i,
                               fields[3].to_i, fields[4].to_i, fields[5].to_i)
    end

    def read_multi
      msg = ""
      while true
        report = read_report
        raise "unexpected message type 0x#{report[:msg_type].to_s(16)}" unless report[:msg_type] == 0x60
        msg += report[:msg]
        break if report[:msg].end_with?("CMD OK\r\n")
      end
      result = extract_text(msg).split("\r\n")
      record_count, checksum = result.pop.split(',')
      raise "wrong number of records: declared #{record_count}, got result.length" unless record_count.to_i == result.length
      validate_checksum!(result.join("\r\n")+"\r\n", checksum.to_i(16))
      result
    end

    def read_text_command
      report = read_report
      raise "unexpected message type 0x#{report[:msg_type].to_s(16)}" unless report[:msg_type] == 0x60
      extract_text(report[:msg])
    end

    def extract_text(msg)
      msg, status = msg.split('CMD ')
      raise "*#{status}" unless status == "OK\r\n"
      msg, checksum = msg.split('CKSM:')
      validate_checksum!(msg, checksum.to_i(16))
      msg
    end

    def validate_checksum!(msg, checksum)
      raise "checksum failed" unless checksum = msg.bytes.reduce(0){ |m, b| m + b }
    end

    def read_report
      reading = @device.read.bytes
      msg_type = reading.shift
      length = reading.shift
      return read_report if msg_type == 0x22 && length == 0x1
      msg = reading.pack('C*')[0...length]
      while msg.length < length
        msg += @device.read.pack('C*')[0...(length - msg.length)]
      end
      {msg_type: msg_type , msg: msg}
    end

    def write_report(cmd, value)
      value = value.bytes
      @device.write([0x00, cmd, value.length, *value, *Array.new(61-value.length, 0x00) ])
    end
  end
end
