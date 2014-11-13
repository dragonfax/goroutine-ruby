# a queue would block by accident
class Channel

  attr_accessor :element, :closed

  def initialize
    @closed = false
    @element = nil
  end

  def read
    if $current_select
      ChannelReadSelector.new(self)
    else
      # outside of a select block
      # Channel.read is just a shortcut for a quick select to read or return nil if closed.
      go_select {
        go_case(ChannelReadSelector.new(self)) { |r| r }
        go_case(ChannelCloseSelector.new(self)) { nil }
      }
    end
  end

  def write(e)
    raise "closed channel" if @closed

    if ! @element.nil?
      Fiber.yield until @element.nil? || @closed
    end

    @element = e
  end

end
