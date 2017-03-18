require 'spec_helper'

module FreestyleLibre
  describe ExportFileParseResult do
    xit 'finds the right number of measurements' do
      result = ExportFileParseResult.new('libre.export')
      num = 0
      File.open('libre.export', "r") do |f|
        while !f.eof?
          f.readline
          num += 1
        end
      end
      # as long as this is the count does not match the total number of line, we are not compler
      expect(result.auto_measurements.length + result.manual_measurements.length).to eq num
    end
  end
end
