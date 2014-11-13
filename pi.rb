#!/usr/bin/env ruby
#
# one of the examples from golang.org
#
# http://play.golang.org/p/rAq95NyaJh
#

require_relative './lib/goroutine'

def pi(n)
  ch = Channel.new
  (0..n-1).each do |k|
    go do
      term(ch, k)
    end
  end
  f = 0.0
  (0..n-1).each do |k|
    f += ch.read
  end
  f
end

# -1 to a power
# power (**) is broken in ruby for negatives operands
def negpow(k)
  if k == 0
    1
  elsif ( k % 2 ) == 0
    1
  else
    -1
  end
end

def term(ch, k)
  ch.write( 4 * negpow(k) / ( 2 * k.to_f + 1 ) )
end

# main
go do
  raise "need an integer argument" unless ARGV.size == 1
  num_goroutines = ARGV[0].to_i
  puts "PI = #{pi(num_goroutines)}"
end

$scheduler.run