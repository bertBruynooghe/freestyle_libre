module FreestyleLibre
  class ExportFileParseResult
    attr_reader :patient_name, :patient_id, :auto_measurements, :manual_measurements

    def initialize(export_file_path)
      @auto_measurements = []
      @manual_measurements = []
      @time_changes = []
      parse_file(export_file_path)
    end


    private

    def parse_file(export_file_path)
      File.open(export_file_path, "r") do |f|
        @patient_name = f.readline.strip
        @patient_id = f.readline.strip[2..-1]
        @columns = f.readline.strip.split("\t")
        while !f.eof?
          parse_line(f.readline)
        end
      end
    end

    def parse_line(line)
      tokens = line.split("\t")
      case tokens[2]
      when '0'
        insert_auto_measurement(tokens)
      when '1'
        insert_manual_measurement(tokens)
      when '4'
        # fast acting insulin
      when '5'
        # food non-numerid
      when '6'
        insert_time_change(tokens)
      else
        puts Hash[@columns.zip(tokens)]
      end
    end

    def insert_time_change(tokens)
    end

    def insert_auto_measurement(tokens)
      @auto_measurements << Record.new(id: tokens[0].to_i,
               date_time: DateTime.strptime("#{tokens[1]}", '%Y-%m-%d %H:%M'),
               first_sensor_reading: nil,
               sensor_runtime_minutes: nil,
               value: tokens[3].to_i,
               errored: false,
               error_code: "0")
    end

    def insert_manual_measurement(tokens)
      @manual_measurements << Record.new(id: tokens[0].to_i,
                                            type: "2",
                                            date_time: DateTime.strptime("#{tokens[1]}", '%Y-%m-%d %H:%M'),
                                            value: tokens[4].to_i
                                            #errored: false)
                                            )
    end
  end
end
