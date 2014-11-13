#!/usr/bin/env ruby
#
# http://matt.aimonetti.net/posts/2012/11/27/real-life-concurrency-in-go/
#
# Fetch multiple web sites at the same time.
#

require_relative './lib/goroutine'

urls = [
  "http://www.rubygems.org/",
  "http://golang.org/",
  "http://www.umsl.edu/",
]

def async_gets(urls)
  ch = Channel.new
  responses = []
  urls.each do |url|
    go do
      puts "fetching #{url}"
      response = http_get(url)
      ch.write(response)
    end
  end

  while true
    go_select {
      go_case(ch.read) { |r|
        puts "#{r} was fetched"
        responses << r
        if responses.size == urls.size
          return responses
        end
      }
      go_case(go_timeout(1)) {
        puts "."
      }
    }
  end

  responses
end

# main
go do
  results = async_gets(urls)
  results.each do |result|
    puts result
  end
end

$scheduler.run
