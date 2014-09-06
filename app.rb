require 'sinatra/base'
require 'redis'
require 'json'
require 'pry'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################
  enable :method_override

  ########################
  # DB Configuration
  ########################
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])

  ########################
  # Routes
  ########################
  get('/') do
    redirect to("/cheeses")
  end

  # THE SEVEN DEADLY ROUTES

  # GET /cheeses
  get("/cheeses") do
    @cheeses = $redis.keys("*cheeses*").map { |cheese| JSON.parse($redis.get(cheese)) }
    render(:erb, :"cheese/index")
  end

  # POST /cheeses
  post("/cheeses") do
    name = params[:name]
    index = $redis.incr("cheese:index")
    cheese = { name: name, id: index }
    $redis.set("cheeses:#{index}", cheese.to_json)
    redirect to("/cheeses")
  end

  # GET /cheeses/new
  get("/cheeses/new") do
    render(:erb, :"cheese/new_form")
  end

  # GET /cheeses/1
  get("/cheeses/:id") do
    id = params[:id]
    raw_cheese = $redis.get("cheeses:#{id}")
    @cheese = JSON.parse(raw_cheese)
    render(:erb, :"cheese/show")
  end

  # GET /cheeses/1/edit
  get("/cheeses/:id/edit") do
    id = params[:id]
    raw_cheese = $redis.get("cheeses:#{id}")
    @cheese = JSON.parse(raw_cheese)
    render(:erb, :"cheese/edit_form")
  end

  # PUT /cheeses/1
  put("/cheeses/:id") do
    name = params[:name]
    id = params[:id]
    updated_cheese = { name: name, id: id }
    $redis.set("cheeses:#{id}", updated_cheese.to_json)
    redirect to("/cheeses/#{id}")
  end

  # DELETE /cheeses/1
  delete("/cheeses/:id") do
    id = params[:id]
    $redis.del("cheeses:#{id}")
    redirect to("/cheeses")
  end

end
