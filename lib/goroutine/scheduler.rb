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

$scheduler = Scheduler.new

