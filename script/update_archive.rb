#!/usr/bin/env ruby

require 'date'
require 'yaml'

# If there are no arguments, exit from this script.
# FIXME: Check given arguments are the valid url
if ARGV.empty?
  puts "usage: #{File.basename(__FILE__)}"
  puts '--------'
  puts "./script/#{File.basename(__FILE__)} {initel_github_urls...}"
  exit
elsif ENV['GITHUB_GRAPHQL_TOKEN'].nil?
  puts 'GITHUB_GRAPHQL_TOKEN must be set. Create one here: https://github.com/settings/tokens'
  exit
end

initels = ARGV.map do |url|
  url_path_split = url.split('/')
  {
    url: url,
    name: url_path_split[-1],
    author_name: url_path_split[3],
    author_url: url_path_split[0..3].join('/'),
  }
}

# Clone
root = File.expand_path("#{File.dirname(__FILE__)}/..")
data_path = "#{root}/data/archives.yml"

current_data = YAML.load_file(data_path)
data = Marshal.load(Marshal.dump(current_data))

# ISO8601 format
# yyyy-MM-ddTHH:mm:ss+09:00
held_date = (Date.parse(data[0]['date']) + 7).strftime('%Y-%m-%dT23:00:%S+09:00')

data.unshift(
  {
    'id' => (data[0]['id'] + 1),
    'date' => "#{(Date.parse(data[0]['date']) + 7)} 23:00",
    'author' => {
      'name' => initels[0][:author_name],
      'url' => `./script/bin/run-query head_commit_query #{initels[0][:url]} #{held_date}`,
    },
    'log' => {
      'url' => data[0]['log']['url'],
    },
  }
)

open(data_path, 'wb') do |f|
  YAML.dump(data, f, indentation: 2)
end
