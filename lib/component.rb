class Component
  attr_accessor :props
  attr_accessor :state

  def initialize(props)
    self.props = props
    self.state = initial_state
  end

  class << self
    def add_handler(*chars, &block)
      @handlers ||= {}
         
      chars.each do |char|
        @handlers[char] = block
      end
    end

    attr_reader :handlers
  end

  def handle(input)
    events = props[:children] && props[:children].detect do |child|
      child.props["active"] == true && child.handle(input)
    end

    return events if events

    self.class.handlers.detect do |chars, fn|
      if chars === input
        events = instance_eval(&fn)

        if valid_events_array?(events)
          events
        else
          []
        end
      end
    end
  end

  def render(window)
    raise NotImplementedError
  end

  private

  def initial_state
    {}
  end

  def set_state(key, value)
    self.state = state.merge(key => value)
  end

  def valid_events_array?(events)
    events.is_a?(Array) && events.all? do |e|
      e.is_a?(Array) && e.first.is_a?(Symbol)
    end
  end
end
