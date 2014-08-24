require 'yaml'
require 'securerandom'
require 'perpetuity'
require 'perpetuity/postgres'
require 'logger'
require 'csv'
require './config/environment.rb'
require 'date'
require 'time'

DB_YML = "./config/database.yml"

Perpetuity.data_source :postgres, 'data_mapper_app_development'

a = Address.new
Perpetuity[Address].insert a
Perpetuity[Address].delete a

b = Company.new
Perpetuity[Company].insert b
Perpetuity[Company].delete b

c = Client.new
Perpetuity[Client].insert c
Perpetuity[Client].delete c

e = LegalContract.new
Perpetuity[LegalContract].insert e
Perpetuity[LegalContract].delete e

f = Person.new
Perpetuity[Person].insert f
Perpetuity[Person].delete f

g = Project.new
Perpetuity[Project].insert g
Perpetuity[Project].delete g

h = TeamMember.new
Perpetuity[TeamMember].insert h
Perpetuity[TeamMember].delete h

i = Document.new
Perpetuity[Document].insert i
Perpetuity[Document].delete i

j = ProjectsTeamMember.new
Perpetuity[ProjectsTeamMember].insert j
Perpetuity[ProjectsTeamMember].delete j


address_inserts = []

CSV.foreach("script/small/addresses.csv") do  |row|
  line1 = row[0].strip
  line2 = row[1] unless row[1]=='nil'
  postcode = row[2] unless row[2]=='nil'
  city = row[3]
  county = row[4]

  address_inserts << "('#{line1}', "+ (line2 ? "'#{line2}'" : "null") + ", " + (postcode ? "'#{postcode}'" : "null") +
      ", '#{city}', '#{county}', now(), now())"
end
#require 'debugger'; debugger
unless address_inserts.empty?
  Perpetuity.data_source.connection.execute("INSERT INTO \"Address\" (line1, line2,\
postcode, city, county, created_at, updated_at) VALUES #{address_inserts.join(', ')}")
  #print "INSERT INTO addresses (line1, line2, postcode, city, county,created_at, updated_at) VALUES #{address_inserts.join(", ")}"
end
puts "________________________________________________________________________"
puts "adresses done"

address_ids = Perpetuity[Address].all.to_a

CSV.foreach("script/small/companies.csv") do  |row|
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

  #projects

  CSV.foreach("script/small/projects.csv") do  |row|
    proj = Project.new
    proj.budget = row[0].strip
    proj.delivery_deadline = row[1]

    proj.status = row[2]
    proj.created_at = Time.now
    proj.updated_at = Time.now
    Perpetuity[Project].insert proj
    #clients left to be inserted
  end

  puts "________________________________________________________________________"
  puts "projects done"

  #legal contracts
  project_ids = Perpetuity[Project].all.to_a
  index_num = 0
  CSV.foreach("script/small/legal_contracts.csv") do  |row|
    contract = LegalContract.new
    contract.project = project_ids[index_num]
    index_num += 1
    contract.signed_on = row[0].strip
    contract.revised_on = row[1]
    contract.created_at = Time.now
    contract.updated_at = Time.now
    contract.copy_stored = row[2]
    contract.title = row[3]
    Perpetuity[LegalContract].insert contract
  end

  puts "________________________________________________________________________"
  puts "contracts done"


  #documents
random_indexes=[4, 15, 17, 15, 16, 13, 4, 15, 8, 11, 3, 11, 4, 6, 14, 0, 0, 13, 4, 19, 19, 1, 0, 7, 19, 11, 0, 12, 7,
                19, 10, 12, 0, 3, 13, 6, 5, 7, 10, 0, 13, 0, 0, 15, 15, 7, 1, 15, 13, 8, 8, 2, 11, 10, 1, 9, 4, 16,
                4, 7, 5, 2, 13, 3, 0, 7, 12, 12, 13, 11, 6, 1, 6, 18, 0, 3, 6, 4, 15, 2, 6, 3, 11, 12, 0, 11, 16, 14,
                15, 0, 10, 13, 19, 19, 12, 4, 17, 15, 7, 18]

  projects = Perpetuity[Project].all.sort(:created_at).to_a
  index_num = 0
  CSV.foreach("script/small/documents.csv") do  |row|

    doc = Document.new
    doc.project =  projects[random_indexes[index_num]]
    index_num += 1
    doc.doc_type = row[0].strip
    doc.doc_name = row[1]
    doc.revision_number = row[2]
    doc.revision_date = row[3]
    doc.created_at = Time.now
    doc.updated_at = Time.now
    Perpetuity[Document].insert doc

    if index_num%100==0
      the_project =  Perpetuity[Project].find(doc.project.id)
      legal_contract = Perpetuity[LegalContract].select { |contract| contract.project.id == the_project.id}.to_a
      doc.contract_id =legal_contract.first.id
    else
      doc.contract_id = "N/A"
    end
    Perpetuity[Document].save doc
  end

  puts "________________________________________________________________________"
  puts "documents done"



  #now insert team_members and people

  CSV.foreach("script/small/team_members.csv") do  |row|
    team_member = TeamMember.new
    team_member.team = row[4]
    team_member.experience_level = row[5]
    team_member.qualification = row[6]
    team_member.lead = row[7]
    team_member.created_at = Time.now
    team_member.updated_at = Time.now
    Perpetuity[TeamMember].insert team_member

    person = Person.new
    person.first_name = row[0].strip
    person.last_name = row[1]
    person.phone_number = row[2]
    person.email = row[3]
    companies = Perpetuity[Company].all.to_a

    person.company = companies.pop
    person.profile_type = "TeamMember"
    person.profile = team_member
    person.created_at = Time.now
    person.updated_at = Time.now
    Perpetuity[Person].insert person
  end

  puts "________________________________________________________________________"
  puts "team members done"


 #projectsteammembers
  projs= Perpetuity[Project].all.to_a

  team_members = []
  num_of_team_members = {"400000" => 1, "500000" => 2, "600000" => 3, "700000" => 4, "800000" => 4, "900000" => 4,
                       "1000000" => 5, "2000000" => 7, "3000000" => 9}

  projs.each do |proj|
    budget = proj.budget.to_i.to_s

    (num_of_team_members["#{budget}"] || 1).times do
      tm = ProjectsTeamMember.new
      tm.project = proj
      if team_members.empty?
        team_members = Perpetuity[TeamMember].all.sort(:created_at).to_a
      end
      tm.team_member = team_members.pop

      Perpetuity[ProjectsTeamMember].insert tm
    end
  end

puts "________________________________________________________________________"
puts "team_members done"

  used_comp_ids = []
  people =  Perpetuity[Person].all.to_a
  Perpetuity[Person].load_association! people, :company
  people.each do |pers|
    used_comp_ids << pers.company.id
  end
  companies = Perpetuity[Company].all.to_a
  company_ids = []
  companies.each do |company|
    company_ids << company unless used_comp_ids.include?(company.id)
  end


  CSV.foreach("script/small/clients.csv") do  |row|
    client = Client.new
    client.pref_method_of_contact = row[4]
    client.pref_hours_of_contact= row[5]
    client.created_at = Time.now
    client.updated_at = Time.now
    Perpetuity[Client].insert client

    person = Person.new
    person.first_name = row[0].strip
    person.last_name = row[1]
    person.phone_number = row[2]
    person.email = row[3]
    person.company = company_ids.pop
    person.profile = client
    person.profile_type = "Client"
    person.created_at = Time.now
    person.updated_at = Time.now
    Perpetuity[Person].insert person
  end

  puts "________________________________________________________________________"
  puts "clients done"