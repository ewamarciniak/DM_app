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

CSV.foreach("script/addresses.csv") do  |row|
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

  #projects

  CSV.foreach("script/projects.csv") do  |row|
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
  CSV.foreach("script/legal_contracts.csv") do  |row|
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
 random_indexes=[76, 104, 67, 35, 94, 165, 80, 134, 77, 127, 68, 27, 38, 142, 61, 22, 85, 25, 28, 68, 78, 137, 169, 115, 52, 69, 38, 64, 168, 170, 1,
                 68, 117, 33, 48, 85, 192, 127, 162, 98, 176, 70, 66, 141, 131, 66, 168, 170, 139, 180, 51, 68, 135, 93, 153, 106, 84, 101, 176, 117,
                 12, 152, 159, 43, 53, 102, 183, 171, 65, 25, 183, 52, 119, 48, 163, 7, 125, 28, 102, 141, 165, 109, 192, 86, 73, 146, 66, 167, 148,
                 135, 165, 162, 7, 57, 116, 178, 83, 194, 147, 40, 110, 183, 119, 136, 93, 67, 143, 191, 82, 44, 12, 103, 141, 159, 66, 149, 128, 84,
                 39, 63, 30, 90, 199, 134, 62, 98, 148, 151, 184, 149, 140, 119, 108, 188, 3, 149, 78, 78, 5, 70, 180, 190, 7, 185, 53, 25, 64, 39, 36,
                 118, 147, 66, 144, 9, 61, 0, 163, 190, 3, 185, 192, 154, 145, 24, 159, 61, 101, 72, 103, 80, 121, 12, 24, 167, 50, 164, 167, 134, 166,
                 16, 162, 147, 95, 26, 34, 192, 66, 195, 20, 35, 152, 139, 104, 125, 146, 154, 38, 26, 152, 94, 166, 142, 119, 85, 180, 160, 108, 162,
                 48, 19, 148, 66, 40, 96, 16, 178, 0, 188, 9, 75, 63, 37, 11, 140, 123, 197, 77, 140, 185, 157, 57, 108, 160, 93, 163, 91, 114, 103, 19,
                 12, 41, 64, 35, 71, 190, 127, 191, 159, 147, 33, 175, 145, 138, 134, 62, 57, 136, 27, 144, 159, 169, 43, 132, 118, 80, 144, 11, 66, 195,
                 2, 68, 86, 39, 3, 189, 3, 69, 72, 194, 190, 45, 45, 190, 164, 106, 157, 137, 0, 43, 35, 1, 98, 78, 141, 93, 195, 115, 85, 3, 182, 10,
                 50, 24, 33, 127, 32, 61, 81, 98, 78, 143, 63, 92, 102, 157, 72, 67, 38, 195, 113, 41, 107, 113, 17, 154, 173, 172, 3, 127, 12, 92, 136,
                 50, 85, 25, 46, 115, 126, 67, 79, 69, 190, 160, 65, 142, 146, 43, 34, 87, 190, 162, 144, 18, 71, 88, 159, 20, 8, 142, 118, 30, 172, 112,
                 112, 65, 83, 35, 148, 192, 47, 174, 108, 78, 31, 8, 54, 133, 120, 81, 66, 20, 51, 81, 8, 0, 103, 37, 73, 162, 182, 193, 80, 41, 138, 90,
                 170, 20, 182, 134, 197, 190, 66, 148, 173, 192, 0, 192, 92, 125, 19, 3, 127, 79, 126, 112, 119, 126, 87, 176, 70, 89, 144, 155, 138, 1,
                 117, 36, 52, 170, 71, 0, 18, 86, 17, 20, 60, 160, 18, 187, 133, 52, 67, 4, 178, 86, 178, 123, 106, 71, 174, 6, 93, 118, 84, 44, 197, 21,
                 149, 87, 174, 110, 5, 143, 61, 198, 120, 57, 23, 151, 0, 14, 148, 191, 39, 11, 157, 93, 95, 195, 141, 156, 58, 6, 106, 27, 160, 6, 102,
                 34, 149, 138, 90, 72, 185, 143, 145, 91, 181, 148, 103, 144, 198, 171, 46, 127, 64, 165, 157, 46, 130, 187, 15, 26, 145, 94, 165, 10, 1,
                 110, 79, 78, 61, 160, 98, 124, 78, 174, 135, 52, 0, 145, 115, 25, 172, 75, 2, 82, 38, 12, 0, 55, 100, 147, 145, 147, 116, 10, 123, 122,
                 55, 94, 131, 123, 22, 168, 18, 157, 82, 32, 136, 140, 77, 112, 142, 73, 81, 95, 18, 80, 140, 34, 176, 85, 115, 153, 20, 135, 146, 136,
                 56, 82, 185, 146, 118, 9, 116, 55, 98, 74, 61, 157, 120, 45, 114, 125, 154, 168, 69, 187, 157, 87, 25, 190, 71, 144, 175, 154, 175, 91,
                 7, 71, 21, 29, 80, 94, 190, 32, 59, 180, 113, 56, 127, 138, 64, 16, 94, 39, 126, 55, 161, 29, 37, 142, 156, 94, 102, 165, 129, 144, 84,
                 107, 51, 162, 61, 189, 155, 157, 48, 23, 170, 156, 126, 132, 87, 138, 58, 44, 142, 187, 20, 39, 170, 0, 153, 176, 76, 7, 64, 2, 157, 154,
                 96, 112, 178, 51, 99, 178, 157, 96, 156, 83, 124, 179, 33, 142, 138, 34, 3, 163, 176, 170, 108, 125, 183, 165, 117, 124, 185, 133, 24, 70,
                 176, 87, 171, 125, 133, 124, 127, 171, 117, 134, 142, 107, 122, 20, 64, 120, 167, 87, 69, 155, 153, 112, 91, 92, 172, 176, 37, 43, 118, 81,
                 161, 193, 50, 94, 135, 86, 133, 76, 26, 165, 93, 51, 71, 49, 193, 178, 37, 60, 155, 152, 99, 6, 155, 39, 7, 81, 58, 31, 38, 193, 162, 186,
                 188, 34, 192, 96, 92, 155, 101, 198, 8, 164, 152, 43, 14, 33, 132, 183, 10, 54, 63, 50, 57, 69, 104, 190, 185, 150, 105, 81, 78, 37, 85, 18,
                 176, 127, 179, 31, 52, 172, 19, 131, 175, 197, 101, 134, 163, 108, 31, 118, 193, 1, 194, 110, 64, 134, 190, 189, 179, 144, 58, 179, 20, 184,
                 93, 69, 60, 35, 20, 170, 134, 65, 71, 83, 167, 14, 184, 105, 60, 130, 91, 111, 66, 61, 85, 128, 103, 129, 168, 189, 59, 65, 124, 96, 96, 111,
                 12, 194, 115, 136, 189, 162, 191, 178, 7, 187, 81, 3, 32, 98, 57, 181, 21, 189, 56, 93, 62, 95, 98, 198, 166, 6, 100, 173, 146, 56, 96, 80,
                 11, 158, 178, 10, 69, 69, 197, 91, 57, 1, 129, 165, 155, 78, 141, 121, 136, 152, 43, 170, 33, 182, 165, 105, 59, 26, 148, 157, 10, 39, 5, 190,
                 109, 186, 94, 150, 192, 64, 36, 148, 187, 121, 87, 90, 181, 164, 102, 16, 69, 157, 10, 19, 192, 68, 145, 117, 154, 151, 163, 20, 10, 52, 10,
                 28, 23, 140, 141, 59, 196, 25, 152, 18, 191, 195, 190, 151, 118, 172, 173, 132, 88, 143, 82, 51, 75, 142, 55, 62, 136, 145, 117, 114, 170, 66,
                 59, 164, 23, 49, 86, 51, 190, 3, 6, 191, 115, 88, 169, 161, 69, 104, 35]
  projects = Perpetuity[Project].all.sort(:created_at).to_a

  legal_contracts = Perpetuity[LegalContract].all.sort(:created_at).to_a
  indexes = [10, 22, 34, 67, 43, 0, 20, 11, 54, 27]
  index_num = 0
  CSV.foreach("script/documents.csv") do  |row|

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
      doc.contract_id = legal_contracts[indexes.pop].id
    else
      doc.contract_id = "N/A"
    end
    Perpetuity[Document].save doc
  end

  puts "________________________________________________________________________"
  puts "documents done"



  #now insert team_members and people

  CSV.foreach("script/team_members.csv") do  |row|
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