require 'google_drive'
require 'json'

module Fluent
  class GoogleSheetsOutput < BufferedOutput
    Fluent::Plugin.register_output('google_sheets', self)

    config_param :credential_file_path, :string
    config_param :spreadsheet_id, :string
    config_param :keys, default: [] do |val|
      val.split(',')
    end

    def format(tag, time, record)
      [tag, Time.at(time).strftime('%F %T'), record].to_json + "\n"
    end

    def write(chunk)
      data = chunk.read.each_line.map {|line| JSON.parse(line) }.group_by {|tag, *| tag }

      data.each do |tag, xs|
        ws = worksheet(tag)
        ws.insert_rows(ws.num_rows + 1, xs.map {|_, time, record| [time] + record.values })
        ws.save
      end
    end

    private

    def headers
      %w(timestamp) + @keys
    end

    def worksheet(tag)
      spreadsheet.worksheet_by_title(tag) || spreadsheet.add_worksheet(tag).tap do |ws|
        ws.insert_rows(1, [headers])
        ws.save
      end
    end

    def spreadsheet
      @spreadsheet ||= begin
        session = GoogleDrive::Session.from_service_account_key(@credential_file_path)
        session.spreadsheet_by_key(@spreadsheet_id)
      end
    end
  end
end
