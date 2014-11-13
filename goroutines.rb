#!/usr/bin/env ruby

require 'fiber'

class Scheduler

  def initialize
    @goroutines = []
  end

  def add(&block)
    @goroutines << Fiber.new do
      begin
        block.call
      ensure
        @goroutines.delete Fiber.current
      end
    end
  end

  def run

    # TODO proper implementation (smarter scheduler)
    # wait until a fiber is ready to run
    # run any fibers that are ready to run
    # loop until they all fibers close down

    until @goroutines.empty?
      @goroutines.each do |g|
        g.resume
      end
    end
  end

end

# a queue would block by accident
class Channel

  attr_accessor :element, :closed

  def initialize
    @closed = false
    @element = nil
  end

  def read
    if ! @close && @element.nil?
      Fiber.yield until @element || @closed
    end

    e = @element
    @element = nil
    return e
  end

  def write(e)
    raise "closed channel" if @closed

    if ! @element.nil?
      Fiber.yield until @element.nil? || @closed
    end

    @element = e
  end

end

$scheduler = Scheduler.new

def go(&block)
  $scheduler.add &block
end

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
  r = ch.write( 4 * negpow(k) / ( 2 * k.to_f + 1 ) )
  puts k, r
  r
end

# main
# http://play.golang.org/p/rAq95NyaJh
go do
  puts "PI = #{pi(ARGV[0].to_i)}"
end

$scheduler.run