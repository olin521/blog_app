# Simple curding app in Sinatra -v 1.0.0


Description: This simple app was created as a WDI project. It's meant to display simple ways to CRUD in a nosql database, such as cola soda brands. Here, Redis Database was used instead of SQL. 

Gems / Languages 
-----

Ruby -v "2.1.2"

Using gems:

gem 'sinatra', '1.4.5'

gem 'redis',   '3.1.0'

gem 'httparty'

gem 'shotgun'

gem 'rspec',    '~> 3.0.0'

gem 'capybara', '~> 2.4.1'

gem 'json'

gem 'securerandom'


Config.
-----

*** Please allow 'Get Add Ons' feature in Heroku for Redis To Go.

*** In the future, a user will sign into the app using their github address, and once authenticated be able to view and contribute to the growing list of cola flavored sodas. 

*** There is a seeds.rb file that must be loaded to the NoSql db before running the app. If deploying from your ternimal window using Heroku run command:

###### $ heroku run ruby seeds.rb

This will ensure your db is seeded with the current list of colas.

All other ENV varibales will have to be locally stored either on your local .bash_profile or on the hosting server in a secure place.


URL
-----
The site is hosted on Heroku:
http://enigmatic-refuge-9837.herokuapp.com/colas

Note
-----
Although an testing environment was set up in the file structure, no testing was done for the site. The Github login is not currently functinal as a result of misdirecting REDITOGO url.


