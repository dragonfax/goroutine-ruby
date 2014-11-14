
def go(&block)
  $scheduler.add &block
end


def go_select(&block)
  raise "select not re-entrant" if $current_select

  # build the select object
  s = Select.new
  $current_select = s
  begin
    block.call
  ensure
    $current_select = nil
  end

  # run the select object
  s.test
end

def go_case(gcase, &block)
  raise "not within a select clause" if $current_select.nil?
  raise "must provide a case condition" if gcase.nil?
  raise "must provide a case block" unless block_given?

  $current_select.add_case(gcase,&block)
end

def go_timeout(ttl)
  TimeoutCase.new(ttl)
end

DEFAULT = DefaultCase.new
