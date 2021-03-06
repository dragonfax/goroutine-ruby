

class Select
  def initialize
    @cases = []
  end

  def add_case(gcase, &block)
    @cases << [gcase, block]
  end

  def test

    while true
      @cases.each do |gcase, block|
        if gcase.ready?
          arguments = gcase.arguments
          return block.call(*arguments)
        end
      end
      Fiber.yield
    end
  end
end

class BaseCase
  def arguments
    []
  end
end

# just wait for a value to be set
class ValueCase

  attr_reader :value

  def initialize
    @value = nil
    @set = false
  end

  def ready?
    @set
  end

  def set_value(value)
    @value = value
    @set = true
  end

  def arguments
    [@value]
  end

end

# wait for a set number of seconds
class TimeoutCase < BaseCase
  def initialize(ttl)
    @timesup = Time.now + ttl
  end

  def ready?
    Time.now > @timesup
  end
end

# always true
class DefaultCase < BaseCase
  def ready?
    true
  end
end

# wait for a channel to close
class ChannelCloseCase < BaseCase
  def initialize(ch)
    @channel = ch
  end

  def ready?
    @channel.closed
  end
end

# wait for a channel to have a message, or be closed
class ChannelReadCase < BaseCase
  def initialize(ch)
    @channel = ch
  end

  def ready?
    ! @channel.element.nil? || @channel.closed
  end

  def arguments
    e = @channel.element
    @channel.element = nil
    [ e ]
  end
end
