
require 'open-uri'

# non-blocking web request
def http_get(url)

  selector = ValueSelector.new

  # TODO need non-blocking http request
  Thread.new do
    selector.set_value(open(url).read)
  end

  while true
    go_select do
      go_case(selector) { |r| return r }
      go_case(go_timeout(1)) { puts "waiting on #{url}"}
    end
  end
end

