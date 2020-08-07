class SampleComponent < Component
  add_handler 'j' do
    if props["active"]
      # update the list

      []
    end
  end

  def initial_state
    {
      "foo" => "bar"
    }
  end
end
