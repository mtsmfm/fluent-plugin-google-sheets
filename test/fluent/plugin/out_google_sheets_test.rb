require 'test_helper'

class Fluent::Plugin::GoogleSheetsOutputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::GoogleSheetsOutput).configure(conf)
  end

  test 'emit' do
    credential_file = TestHelper.credential_file

    VCR.use_cassette('emit') do
      d = create_driver(<<~CONF)
        credential_file_path #{credential_file.path}
        spreadsheet_id #{TestHelper.spreadsheet_id}
        keys foo
      CONF

      time = event_time
      d.run do
        d.feed('output.test', time, {'foo' => 'bar'})
      end

      assert_requested(:put, %r|https://sheets.googleapis.com/v4/spreadsheets/#{TestHelper.spreadsheet_id}/values/'output.test'|, times: 1) do |req|
        JSON.parse(req.body)['values'] == [[time.to_time.strftime('%F %T'), "bar"]]
      end
    end
  end
end
