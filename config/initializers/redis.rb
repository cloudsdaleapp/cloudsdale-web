require "connection_pool"
$redis ||= ConnectionPool::Wrapper.new(size: 8, timeout: 3) do
  Figaro.load
  Redis.new url: Figaro.env.redis_url!
end