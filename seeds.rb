require 'json'
require 'redis'

$redis = Redis.new(url: ENV["REDISTOGO_URL"])

# Clear out any old data
$redis.flushdb

# Create a counter to track indexes
$redis.set("cheese:index", 0)

puts "Importing data..."

cheese_data = JSON.parse(File.read("cheese_data.json"))

# Set cheeses
cheese_data["cheese_data"].each do |cheese|
  # Setting an index by incrementing a counter rather than using keys.size
  index = $redis.incr("cheese:index")
  cheese[:id] = index
  # keys.count and each_with_index won't work properly because there's no guarantee of order with a hash
  $redis.set("cheeses:#{index}", cheese.to_json)
end

# Set stank levels
cheese_data.select { |key, value| key.include? "stank" }.each do |level, adjective|
  $redis.set(level, adjective)
end

# Set country codes
$redis.set("country_codes", cheese_data["country_codes"].to_json)

puts "Imported #{$redis.keys.count} records"
