require 'json'
require 'redis'

$redis = Redis.new(url: ENV["REDISTOGO_URL"])

# Clear out any old data
$redis.flushdb

# Create a counter to track indexes
$redis.set("cola:index", 0)

puts "Importing data..."

cola_data = JSON.parse(File.read("cola_data.json"))

# Set cheeses
cola_data["cola_data"].each do |cola|
  # Setting an index by incrementing a counter rather than using keys.size
  index = $redis.incr("cola:index")
  cola[:id] = index
  # keys.count and each_with_index won't work properly because there's no guarantee of order with a hash
  $redis.set("colas:#{index}", cola.to_json)
end

# Set stank levels
cola_data.select { |key, value| key.include? "taste" }.each do |level, adjective|
  $redis.set(level, adjective)
end

# Set country codes
$redis.set("country_codes", cola_data["country_codes"].to_json)

puts "Imported #{$redis.keys.count} records"
