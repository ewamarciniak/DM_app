require 'yaml'
require 'securerandom'
require 'perpetuity'
require 'perpetuity/postgres'
require 'logger'
require 'csv'
require './config/environment.rb'

DB_YML = "./config/database.yml"

Perpetuity.data_source :postgres, 'data_mapper_app_development'

  address_inserts = []

  CSV.foreach("script/addresses.csv") do  |row|
    line1 = row[0].strip
    line2 = row[1] unless row[1]=='nil'
    postcode = row[2] unless row[2]=='nil'
    city = row[3]
    county = row[4]

    address_inserts << "('#{line1}', "+ (line2 ? "'#{line2}'" : "null") + ", " + (postcode ? "'#{postcode}'" : "null") +
        ", '#{city}', '#{county}', now(), now())"
  end
 require 'debugger'; debugger
  unless address_inserts.empty?
    Perpetuity::Postgres.execute("INSERT INTO 'Address' (line1, line2,\
postcode, city, county, created_at, updated_at) VALUES #{address_inserts.join(', ')}")
    #print "INSERT INTO addresses (line1, line2, postcode, city, county,created_at, updated_at) VALUES #{address_inserts.join(", ")}"
  end
  puts "________________________________________________________________________"
  puts "adresses done"