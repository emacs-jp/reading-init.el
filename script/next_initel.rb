#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'date'
require 'yaml'

# If there are no arguments, exit from this script.
# FIXME: Check given arguments are the valid url
if ARGV.empty?
  puts "usage: #{File.basename(__FILE__)}"
  puts '--------'
  puts "./script/#{File.basename(__FILE__)} {next_initel_github_urls...}"
  exit
end

# Read URL from given arguments: Support only GitHub right now
next_initels = ARGV.map {|url|
  url_path_split = url.split('/')
  {
    url: url,
    name: url_path_split[-1],
    author_name: url_path_split[3],
    author_url: url_path_split[0..3].join('/'),
  }
}

# Clone
root = File::expand_path("#{File::dirname(__FILE__)}/..")
next_data_path = "#{root}/data/next.yml"

current_data = YAML.load_file(next_data_path)
next_data = Marshal.load(Marshal.dump(current_data))

# first data
f_current = current_data[0]
f_next = next_data[0]

f_next['id'] = f_current['id'] + 1
f_next['date'] = "#{(Date.parse(f_current['date']) + 7)} 22:00"

# Update next init.el
f_next['initels'] = next_initels.map {|initel|
  {
    'url' => initel[:url],
    'name' => initel[:name],
    # 'hash' => nil, # TODO: consider hash
  }
}

f_next['author'] = {
  'name' => next_initels[0][:author_name], # Assume same
  'url'  => next_initels[0][:author_url],  # Assume same
}

# Others
# f_next['part'] = nil # Deal with parts
# f_next['other'] = nil

# IO
open(next_data_path, "wb") {|f|
  YAML.dump(next_data, f, indentation: 2)
}

# Finally
puts 'Successfully updating next init.el'
puts 'Make sure the update is correct with git diff or whatever :)'
