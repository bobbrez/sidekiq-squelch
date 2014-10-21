def redis_add_queues(queues)
  Sidekiq.redis do |redis|
    queues.each { |q| redis.sadd Dynamiq::QUEUE_LIST, q }
  end
end

def redis_queue_job(dynamic_queue, score, args = nil)
  payload = { retry: true, class: "Foo", jid: SecureRandom.hex, enqueued_at: Time.now.to_f }
  payload.merge! queue: dynamic_queue, score: score, args: args

  Sidekiq.redis do |redis|
    redis.zadd [Dynamiq::QUEUE_LIST, dynamic_queue].join(':'), score, payload.to_json
  end

  payload
end
