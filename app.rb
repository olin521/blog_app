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


    render(:erb, :"cola/index")
  end
  get('/about') do


    render(:erb, :"cola/index")
  end

  # THE SEVEN DEADLY ROUTES

  # GET /cheeses
  get("/colas") do
    @colas = $redis.keys("*colas*").map { |cola| JSON.parse($redis.get(cola)) }
    render(:erb, :"cola/list")
  end

  # POST /cheeses
  post("/colas") do
    name = params[:name]
    country = params[:country]
    sugar_type = params[:sugar_type]
    taste_level = params[:taste_level]
    desc = params[:desc]
    image_url = params[:image_url]
    index = $redis.incr("cola:index")
    cola = { name: name, id: index, country: country, sugar_type: sugar_type, taste_level: taste_level, desc: desc, image_url: image_url }
    $redis.set("colas:#{index}", cola.to_json)
    redirect to("/colas")
  end

  # GET /cheeses/new
  get("/colas/new") do
    render(:erb, :"cola/new_form")
  end

  # GET /cheeses/1
  get("/colas/:id") do
    id = params[:id]
    raw_cola = $redis.get("colas:#{id}")
    @cola = JSON.parse(raw_cola)
    render(:erb, :"cola/show")
  end

  #### POST /cheeses/1/comment
  post("/colas/:id/#comments") do
    user_name = params[:user_name]
    comment = params[:comment]
    index = $redis.incr("comment:index")
    comment = { user_name: user_name, id: index, comment: comment }
    $redis.set("comments:#{index}", comment.to_json)
    redirect to("/colas/:id")
  end

  # GET /cheeses/1/edit
  get("/colas/:id/edit") do
    id = params[:id]
    raw_cola = $redis.get("colas:#{id}")
    @cola = JSON.parse(raw_cola)
    render(:erb, :"cola/edit_form")
  end

  # PUT /cheeses/1
  put("/colas/:id") do
    name = params[:name]
    id = params[:id]
    country = params[:country]
    sugar_type = params[:sugar_type]
    taste_level = params[:taste_level]
    desc = params[:desc]
    image_url = params[:image_url]
    updated_cola = { name: name, id: id, country: country, sugar_type: sugar_type, taste_level: taste_level, desc: desc, image_url: image_url }
    $redis.set("colas:#{id}", updated_cola.to_json)
    redirect to("/colas/#{id}")
  end

  # DELETE /cheeses/1
  delete("/colas/:id") do
    id = params[:id]
    $redis.del("colas:#{id}")
    redirect to("/colas")
  end

end
