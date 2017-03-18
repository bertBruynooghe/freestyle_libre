module FreestyleLibre
  class Report
    attr_reader :data

    def initialize(data)
      @data = case data
      when String
        data.bytes
      else
        payload = data[:payload]
        [0x00, data[:command], payload.length, *payload, *Array.new(61-payload.length, 0x00) ]
      end
    end

    def message_type
      @data[0]
    end

    def message
      @data[2...2+len]
    end

    def to_s
      "#{message_type.to_s(16)}: #{message.map{|b| b.to_s(16)}.join(', ')}"
    end

    private

    def len
      @data[1]
    end
  end
end
