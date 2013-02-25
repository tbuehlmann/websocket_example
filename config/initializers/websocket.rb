EM.next_tick do
  puts 'STAAAAAARTED.'
  @channel = EM::Channel.new

  # Simulate messages.
  EM::PeriodicTimer.new(2) do
    random_string = rand(100_000).to_s
    @channel.push random_string
  end

  @subscriptions = {}

  EM::WebSocket.run(:host => '0.0.0.0', :port => 8080) do |ws|
    ws.onopen do
      subscriber_id = @channel.subscribe do |msg|
        ws.send msg
      end

      @subscriptions[ws.signature] = subscriber_id
    end

    ws.onclose do
      subscriber_id = @subscriptions.delete(ws.signature)
      @channel.unsubscribe subscriber_id
    end
  end
end
