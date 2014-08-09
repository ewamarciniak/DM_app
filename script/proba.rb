require 'yaml'
require 'securerandom'
require 'perpetuity'
require 'perpetuity/postgres'
require 'logger'
require 'csv'
require './config/environment.rb'

DB_YML = "./config/database.yml"

Perpetuity.data_source :postgres, 'data_mapper_app_development'

address_ids = Perpetuity[Address].all.to_a

CSV.foreach("script/companies.csv") do  |row|
  company_name = row[0].strip
  fax_number = row[1] unless row[1]=='nil'
  phone_number = row[2] unless row[2]=='nil'
  reg_number = row[3]
  a = address_ids.pop

  b = Company.new
  b.address = a
  b.company_name = company_name
  b.fax_number = fax_number
  b.phone_number = phone_number
  b.reg_number = reg_number
  b.created_at = Time.now
  b.updated_at = Time.now
  b.address.created_at = b.address.created_at.to_s
  b.address.updated_at = b.address.updated_at.to_s
  Perpetuity[Company].insert b
end

puts "________________________________________________________________________"
puts "companies done"