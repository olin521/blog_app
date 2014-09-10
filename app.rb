require 'sinatra/base'
require 'redis'
require 'json'
#require 'pry'
# OAuth
require 'httparty'
require 'securerandom'
require 'uri'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################
  enable :method_override
  enable :logging
  enable :sessions
  # set the secret yourself, so all your application instances share it:
  set :session_secret, 'super secret'
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



  #######################
  # API KEYS
  #######################
  CLIENT_ID     = ENV["GITHUB_CLIENT_ID"]
  CLIENT_SECRET = ENV["GITHUB_CLIENT_SECRET"]
  CALLBACK_URL  = "http://www.heroku.com/oauth_callback"
  #######################

  ########################
  # Routes
  ########################
  get('/') do
    base_url = "https://github.com/login/oauth/authorize"
    scope = "user"
    # generate a random string of characters
    state = SecureRandom.urlsafe_base64
    # storing state in session because we need to compare it in a later request
    session[:state] = state
    # turn the hash into a query string
    query_params = URI.encode_www_form({
                  :client_id    => CLIENT_ID,
                  :scope        => scope,
                  :redirect_uri => CALLBACK_URL,
                  :state        => state
                                       })
    @url = base_url + "?" + query_params
    render(:erb, :"cola/oauth")
  end

get('/oauth_callback') do
    code = params[:code]
    # compare the states to ensure the information is from who we think it is
    if session[:state] == params[:state]
      # send a POST
      response = HTTParty.post("https://github.com/login/oauth/access_token",
                      :body => {
                      :client_id     => CLIENT_ID,
                      :client_secret => CLIENT_SECRET,
                      :code          => code,
                      :redirect_uri  => CALLBACK_URL
                                         },
                      :headers => {
                      "Accept" => "application/json"
                      })
      session[:access_token] = response["access_token"]
    end
    redirect to("/colas")
  end

  get('/about') do


    render(:erb, :"cola/about")
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
    comments = []
    index = $redis.incr("cola:index")

    cola = { name: name, id: index, country: country, sugar_type: sugar_type, taste_level: taste_level, desc: desc, image_url: image_url, comments:[] }
    $redis.set("colas:#{index}", cola.to_json)
    redirect to("/colas")
  end

  # POST /cheeses/1/comments ##
  post("/colas/:id/comments") do
    id = params[:id]
    @cola = JSON.parse($redis.get("colas:#{id}"))
    comment = {user_name: params["user_name"],
    user_comment: params["user_comment"]}
    @cola["comments"].push(comment)
    $redis.set("colas:#{id}",@cola.to_json)
    redirect to("/colas/#{id}")
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

  # #### POST /cheeses/1/#comments
  # post("/colas/:id/#comments") do
  #   user_name = params[:user_name]
  #   comment = params[:comment]
  #   index = $redis.incr("comment:index")
  #   comment = { user_name: user_name, id: index, comment: comment }
  #   $redis.set("comments:#{index}", comment.to_json)
  #   redirect to("/colas/:id")
  # end

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
    comments = []

    updated_cola = { name: name, id: id, country: country, sugar_type: sugar_type, taste_level: taste_level, desc: desc, image_url: image_url, comments:[] }
    $redis.set("colas:#{id}", updated_cola.to_json)
    redirect to("/colas/#{id}")
  end

  # DELETE /cheeses/1
  delete("/colas/:id") do
    id = params[:id]
    $redis.del("colas:#{id}")
    redirect to("/colas")
  end

   get('/logout') do
    session[:access_token] = nil
    redirect to("/")
    render(:erb, :"cola/logout")
  end

end
