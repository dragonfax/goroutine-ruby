
require 'open-uri'


# non-blocking web request
def http_get(url)

  # TODO need true non-blocking http request
  non_blocking {
    open(url).read
  }

end

