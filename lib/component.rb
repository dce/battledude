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
      child.handle(input)
    end

    return events if events

    self.class.handlers.detect do |chars, fn|
      if chars === input
        events = instance_eval(&fn)

        unless events.is_a?(Array) && events.all? { |e| e.is_a?(Array) }
          raise "Handlers must return event array"
        end

        return events
      end
    end
  end

  def render

  end

  private

  def initial_state
    {}
  end

  def set_state(key, value)
    self.state = state.merge(key => value)
  end
end
