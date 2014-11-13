

class Select
  def initialize
    @cases = []
  end

  def add_case(selector, &block)
    @cases << [selector, block]
  end

  def test

    while true
      @cases.each do |selector, block|
        if selector.ready?
          arguments = selector.arguments
          return block.call(*arguments)
        end
      end
      Fiber.yield
    end
  end
end

class BaseSelector
  def arguments
    []
  end
end

class ValueSelector

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



class TimeoutSelector < BaseSelector
  def initialize(ttl)
    @timesup = Time.now + ttl
  end

  def ready?
    Time.now > @timesup
  end
end


class DefaultSelector < BaseSelector
  def ready?
    true
  end
end


class ChannelCloseSelector < BaseSelector
  def initialize(ch)
    @channel = ch
  end

  def ready?
    @channel.closed
  end
end

class ChannelReadSelector < BaseSelector
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


