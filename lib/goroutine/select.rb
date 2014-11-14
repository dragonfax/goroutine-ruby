

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



class TimeoutCase < BaseCase
  def initialize(ttl)
    @timesup = Time.now + ttl
  end

  def ready?
    Time.now > @timesup
  end
end


class DefaultCase < BaseCase
  def ready?
    true
  end
end


class ChannelCloseCase < BaseCase
  def initialize(ch)
    @channel = ch
  end

  def ready?
    @channel.closed
  end
end

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


