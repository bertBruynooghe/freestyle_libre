require 'spec_helper'

module FreestyleLibre
  describe Reader do
    before{ allow_any_instance_of(Record).to receive(:'=='){ |a, b| a.eql? b } }
    around do |example|
      @reader = FreestyleLibre::Reader.new
      example.run
      @reader.close
    end
    context '#serial' do
      subject{ @reader.serial }
      it{ is_expected.to eq ENV['SERIAL'] }
    end
    context '#software_version' do
      subject{ @reader.software_version }
      it{ is_expected.to eq ENV['SW_VER'] }
    end
    context '#date_time' do
      around do |example|
        date_time = @reader.date_time
        example.run
        @reader.date_time = date_time
      end
      let(:date_time){ DateTime.new(1999, 05, 21, 13, 59)}
      it 'can be written and read' do
        @reader.date_time = date_time
        expect(@reader.date_time).to eq date_time
      end
    end
    context '#patient_name' do
      around do |example|
        @patient_name = @reader.patient_name
        example.run
        @reader.patient_name = @patient_name
      end
      it 'matches the export content' do
        expect(@reader.patient_name).to eq FreestyleLibre::ExportFileParseResult.new('libre.export').patient_name
      end
      it 'can be written and read' do
        @reader.patient_name = @patient_name.reverse
        expect(@reader.patient_name).to eq @patient_name.reverse
      end
    end
    describe '#patient_id' do
      around do |example|
        @patient_id = @reader.patient_id
        example.run
        @reader.patient_id = @patient_id
      end
      it 'matches the export content' do
        expect(@reader.patient_id).to eq FreestyleLibre::ExportFileParseResult.new('libre.export').patient_id
      end
      it 'can be written and read' do
        @reader.patient_id = @patient_id.reverse
        expect(@reader.patient_id).to eq @patient_id.reverse
      end
    end
    describe '#database_record_number' do
      #TODO: we should probably make this test more exact
      subject{ @reader.database_record_number }
      it{ is_expected.to be >= ExportFileParseResult.new('libre.export').auto_measurements.last.id }
    end
    describe '#history' do
      let(:from_export_file){ ExportFileParseResult.new('libre.export').auto_measurements.sort_by(&:id) }
      let(:from_scanner){ @reader.history.sort_by(&:id) }
      let(:valid_from_scanner){ from_scanner.delete_if(&:errored) }
      context 'ids' do
        before{ allow_any_instance_of(Record).to receive(:eql?){ |a, b| a.id == b.id } }
        it 'cover the export file' do
          expect(from_export_file - valid_from_scanner).to be_empty
        end
        it 'is covered by the export file' do
          expect(valid_from_scanner - from_export_file).to be_empty
        end
      end
      context 'values' do
        before{ allow_any_instance_of(Record).to receive(:eql?){ |a, b| (a.value-b.value).abs <= 1 } }
        it 'equals the values from the export file' do
          valid_from_scanner.each_with_index do |f, i|
            expect(f).to eq from_export_file[i]
         end
        end
      end
      context 'date_times' do
        before{ allow_any_instance_of(Record).to receive(:eql?){ |a, b| a.date_time == b.date_time } }
        it 'equals the date_times from the export file' do
           valid_from_scanner.each_with_index { |r, i| expect(r).to eq from_export_file[i] }
        end
      end
      describe '#sensor_runtime_minutes' do
        it 'is smaller than two weeks' do
          expect(valid_from_scanner.map(&:sensor_runtime_minutes).sort.first).to be < (2 * 7 * 24 * 60)
        end
      end
    end
    describe '#arresult' do
      context 'manual_measurements' do
        let(:from_export_file){ ExportFileParseResult.new('libre.export').manual_measurements.sort_by(&:id) }
        let(:from_scanner){ @reader.arresult.select{ |r| r.type == "2" }.sort_by(&:id) }

        let(:valid_from_scanner){ from_scanner.delete_if(&:errored) }
        context 'ids' do
          before{ allow_any_instance_of(Record).to receive(:eql?){ |a, b| a.id == b.id } }
          it 'cover the export file' do
            expect(from_export_file - valid_from_scanner).to be_empty
          end
          it 'is covered by the export file' do
            expect(valid_from_scanner - from_export_file).to be_empty
          end
        end
        context 'values' do
          before{ allow_any_instance_of(Record).to receive(:eql?){ |a, b| a.value == b.value } }
          it 'equals the values from the export file' do
            valid_from_scanner.each_with_index { |r, i| expect(r).to eq from_export_file[i] }
          end
        end
        context 'date_times' do
          before{ allow_any_instance_of(Record).to receive(:eql?){ |a, b| a.date_time == b.date_time } }
          it 'equals the date_times from the export file' do
             valid_from_scanner.each_with_index { |r, i| expect(r).to eq from_export_file[i] }
          end
        end
        context 'errored' do
          it 'has only zero values' do
            from_scanner.select(&:errored).each { |r| expect(r).to have_attributes(value: 0) }
          end
        end
      end
    end
  end
end
