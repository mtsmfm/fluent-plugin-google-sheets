# fluent-plugin-google-sheets

Fluentd output plugin to store data on Google Sheets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-google-sheets'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-google-sheets

## Usage

```
<match example>
  @type google_sheets

  credential_file_path path_to_your_service_account_credential
  spreadsheet_id your_spreadsheet_id
</match>
```

### Note

1. Be sure to enable Drive API and Google Sheets API

- https://console.cloud.google.com/apis/library/drive.googleapis.com
- https://console.cloud.google.com/apis/library/sheets.googleapis.com

2. Be sure to share the spreadsheet with the service account

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mtsmfm/fluent-plugin-google-sheets.
