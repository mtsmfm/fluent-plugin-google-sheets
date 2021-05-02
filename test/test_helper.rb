$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'warning'
Gem.path.each do |path|
  Warning.ignore(//, path)
end
require 'fluent/test'
require 'fluent/test/driver/output'
require 'fluent/test/helpers'
require 'fluent/plugin/out_google_sheets'
require 'pry-byebug'
require 'webmock/test_unit'
require 'vcr'

module TestHelper
  class << self
    def spreadsheet_id
      if ENV['TEST_AGAINST_REAL_GOOGLE_SHEET'] == '1'
        ENV['SPREADSHEET_ID']
      else
        'SPREADSHEET_ID'
      end
    end

    def credential_file
      if ENV['TEST_AGAINST_REAL_GOOGLE_SHEET'] == '1'
        File.open(File.join(__dir__, '..', 'service-account-file.json'))
      else
        rsa = OpenSSL::PKey::RSA.generate(512)
        Tempfile.new(['account', '.json']).tap do |file|
          file.write({
            "type": "service_account",
            "project_id": "project_id",
            "private_key_id": "private_key_id",
            "private_key": rsa.to_pem,
            "client_email": "client_email",
            "client_id": "client_id",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "client_x509_cert_url"
          }.to_json)

          file.flush
        end
      end
    end
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock

  c.before_record do |i|
    if i.request.uri == "https://www.googleapis.com/drive/v3/files/#{TestHelper.spreadsheet_id}?fields=*&supportsAllDrives=true"
      i.response.body = JSON.parse(i.response.body).slice(*%w(kind name id mimeType)).to_json
    end
  end

  c.filter_sensitive_data('<TOKEN>') do |interaction|
    auth = interaction.request.headers['Authorization']&.first
    auth.scan(/Bearer (.*)/)[0][0] if auth
  end

  c.filter_sensitive_data('<TOKEN>') do |interaction|
    JSON.parse(interaction.response.body)['access_token']
  end

  c.filter_sensitive_data('SPREADSHEET_ID') do
    ENV['SPREADSHEET_ID']
  end

  c.filter_sensitive_data('<OAUTH_REQUEST>') do |interaction|
    if interaction.request.uri.include?('oauth')
      interaction.request.body
    end
  end
end
