require 'sinatra/base'
require 'redis'
require 'json'
require 'pry'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################
  enable :method_override
  enable :logging
  ########################
  # DB Configuration
  ########################
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])


  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

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
    country = params[:country]
    milk_type = params[:milk_type]
    stank_level = params[:stank_level]
    desc = params[:desc]
    image_url = params[:image_url]
    index = $redis.incr("cheese:index")
    cheese = { name: name, id: index, country: country, milk_type: milk_type, stank_level: stank_level, desc: desc, image_url: image_url }
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
    country = params[:country]
    milk_type = params[:milk_type]
    stank_level = params[:stank_level]
    desc = params[:desc]
    image_url = params[:image_url]
    updated_cheese = { name: name, id: id, country: country, milk_type: milk_type, stank_level: stank_level, desc: desc, image_url: image_url }
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
