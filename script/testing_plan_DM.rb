require 'yaml'
require 'securerandom'
require 'perpetuity'
require 'perpetuity/postgres'
require 'logger'
require 'csv'
require './config/environment.rb'
require 'date'
require 'time'
require 'benchmark'

DB_YML = "./config/database.yml"

Perpetuity.data_source :postgres, 'data_mapper_app_development'
#Perpetuity.logger = Logger.new(STDOUT)
#TRAVERSALS

#T1: Raw traversal speed************************************************************************************************
#Traverse the Person hierarchy. As each team_member is visited, visit each of its referenced unshared Projects. As each
# project is visited, perform a depth first search on its graph of documents. Return a count of the number of documents
# visited when done./NO DEPTH FIRST SEARCH
def traversal_1

  all_people = Perpetuity[Person].select {|person| person.profile_type == "TeamMember" }.to_a
  docs = 0
  all_people.each do |person|
    projects = []
    team_member = Perpetuity[TeamMember].find(person.profile.id)
    projects_team_members = Perpetuity[ProjectsTeamMember].select {|ptm| ptm.team_member.id == team_member.id}.to_a
    Perpetuity[ProjectsTeamMember].load_association! projects_team_members, :projects

    projects_team_members.each do |projtm|
      projects << projtm.project
    end
    projects.each do |project|
      documents = Perpetuity[Document].select {|document| document.project.id == project.id }.to_a
      documents.each do |doc|
        #visiting instead of returning the size
        docs += 1
      end
    end
  end
  return docs
end

#Traversal T2: Traversal with updates***********************************************************************************
#Repeat Traversal T1, but update objects during the traversal. There are three types of update patterns in this
# traversal. In each, a single update to a document consists of swapping its (signed_on, revised_on) attributes. The three types of
# updates are:
#A)	Update one document per project.
#B)	Update every document as it is encountered.
#C)	Update each document in a project four times

def traversal_2a
  all_people = Perpetuity[Person].select {|person| person.profile_type == "TeamMember" }.to_a
  doc_num = 0
  all_people.each do |person|
    projects = []
    team_member = Perpetuity[TeamMember].find(person.profile.id)
    projects_team_members = Perpetuity[ProjectsTeamMember].select {|ptm| ptm.team_member.id == team_member.id}.to_a
    Perpetuity[ProjectsTeamMember].load_association! projects_team_members, :projects

    projects_team_members.each do |projtm|
      projects << projtm.project
    end
    projects.each do |project|
      doc_index = 0
      documents = Perpetuity[Document].select {|document| document.project.id == project.id }.to_a
      documents.each do |doc|
        #visiting instead of returning the size
        doc_num += 1
        if doc_index == 0
          type = doc.doc_type
          name = doc.doc_name
          doc.doc_type = name
          doc.doc_name = type
          Perpetuity[Document].save doc
        end
        doc_index +=1
      end
    end
  end
  return doc_num
end

def traversal_2b
  all_people = Perpetuity[Person].select {|person| person.profile_type == "TeamMember" }.to_a
  doc_num = 0
  all_people.each do |person|
    projects = []
    team_member = Perpetuity[TeamMember].find(person.profile.id)
    projects_team_members = Perpetuity[ProjectsTeamMember].select {|ptm| ptm.team_member.id == team_member.id}.to_a
    Perpetuity[ProjectsTeamMember].load_association! projects_team_members, :projects

    projects_team_members.each do |projtm|
      projects << projtm.project
    end
    projects.each do |project|
      documents = Perpetuity[Document].select {|document| document.project.id == project.id }.to_a
      documents.each do |doc|
        #visiting instead of returning the size
        doc_num += 1
        type = doc.doc_type
        name = doc.doc_name
        doc.doc_type = name
        doc.doc_name = type
        Perpetuity[Document].save doc
      end
    end
  end
  return doc_num
end

def traversal_2c

  all_people = Perpetuity[Person].select {|person| person.profile_type == "TeamMember" }.to_a
  doc_num = 0
  all_people.each do |person|
    projects = []
    team_member = Perpetuity[TeamMember].find(person.profile.id)
    projects_team_members = Perpetuity[ProjectsTeamMember].select {|ptm| ptm.team_member.id == team_member.id}.to_a
    Perpetuity[ProjectsTeamMember].load_association! projects_team_members, :projects

    projects_team_members.each do |projtm|
      projects << projtm.project
    end
    projects.each do |project|
      documents = Perpetuity[Document].select {|document| document.project.id == project.id }.to_a
      documents.each do |doc|
        #visiting instead of returning the size
        doc_num += 1
        type = doc.doc_type
        name = doc.doc_name
        doc.doc_type = name
        doc.doc_name = type
        4.times do
          Perpetuity[Document].save doc
        end
      end
    end
  end
  return doc_num
end


#Traversal T3: Traversal with indexed field updates*********************************************************************
#Repeat Traversal T2, except that now the update is on the date field, which is indexed. The specific update is to
# increment the date if it is odd, and decrement the date if it is even.



#Traversal T6: Sparse traversal speed***********************************************************************************
#Traverse the person hierarchy. As each team member is visited, visit each of its referenced unshared projects. As each
# project is visited, visit the root document Return a count of the number of documents visited when done.

#Traversals T8 and T9: Operations on Manual.
#Traversal T8***********************************************************************************************************
#Scans the address object, counting the number of occurrences of the character “I.”
def traversal_8
  num_occurances = 0
  Perpetuity[Address].all.to_a.each do |address|
     full_ad = address.line1 + ' '  + (address.line2 || '') + ' '  + address.city + address.county
     occurance = full_ad.downcase.scan(/i/).size
     num_occurances += occurance
  end
  return num_occurances
end

#Traversal T9***********************************************************************************************************
#Checks to see if the first and last character in the address object are the same.
def traversal_9
  num_occurances = 0
  Perpetuity[Address].all.to_a.each do |address|
    num_occurances += 1 if address.city.downcase.split('').first == address.city.downcase.split('').last
  end
  return num_occurances
end


#QUERIES

#Query Q1: exact match lookup*******************************************************************************************
#Generate 10 random Document ids; for each generated lookup the document with that id. Return the number of documents
#processed when done.
def query_1
  #document_ids = Document.pluck(:id)
  document_ids = Perpetuity[Document].all.to_a.map(&:id)
  index_num = [ 342, 876, 44, 299, 908, 112, 4, 77, 643, 999]
  all_ids = []
  index_num.each do |num|
    all_ids << document_ids[num]
  end

  processed_number = 0
  all_ids.each do |id|
    Perpetuity[Document].find(id)
    processed_number+=1
  end
  return processed_number
end

#Queries Q2, Q3, and Q7.
#Query Q2***************************************************************************************************************
#Choose a range for dates that will contain the last 1% of the dates found in the database's Documents. Retrieve the
#Documents that satisfy this range predicate.
def query_2
  start_date = '2014-03-29'
  end_date = '2014-08-05'
  documents = Perpetuity[Document].select { |document| document.revision_date > start_date}.select { |document| document.revision_date < end_date}

  return documents.to_a.size
end

#Query Q3***************************************************************************************************************
#Choose a range for dates that will contain the last 10% of the dates found in the database's Documents. Retrieve the
# Documents that satisfy this range predicate.
def query_3
  start_date = '2014-01-10'
  end_date = '2014-01-20'
  documents = Perpetuity[Document].select { |document| document.revision_date > start_date}.select { |document| document.revision_date < end_date}
  return documents.to_a.size
end

#Query Q4: path lookup**************************************************************************************************
#Generate 100 random legal_contract titles. For each title generated, find all TeamMembers that use the project
#corresponding to the legal_contract. Also, count the total number of team_members that qualify.

def query_4
  team_members_num = 0
  team_members =[]
  contracts = Perpetuity[LegalContract].all.to_a
  Perpetuity[LegalContract].load_association! contracts, :project
  projects = Perpetuity[Project].all.to_a
  Perpetuity[Project].load_association! projects, :projects_team_members
  proj_team_members = Perpetuity[ProjectsTeamMember].all.to_a
  Perpetuity[ProjectsTeamMember].load_association! proj_team_members, :team_members
  contracts.each do |contract|
    ptms = Perpetuity[ProjectsTeamMember].select {|ptm| ptm.project.id == contract.project.id }.to_a
    team_members_num += ptms.size
  end
  return team_members_num
end

#Query Q5: single-level make********************************************************************************************
#Find all Team_members that use a project with a build date later than the build date of the team_member. Also, report
#the number of qualifying team_members found.
def query_5
  relevant_team_members = []
  all_projects = Perpetuity[Project].all.to_a
  all_projects.each do |proj|
    ptms = Perpetuity[ProjectsTeamMember].select {|ptm| ptm.project.id == proj.id }.to_a
    Perpetuity[ProjectsTeamMember].load_association! ptms, :team_member
    Perpetuity[ProjectsTeamMember].load_association! ptms, :project

    ptms.each do |pt|
      tm_created_at = pt.team_member.created_at
      pt_created_at =  pt.project.created_at

      if tm_created_at < pt_created_at
        relevant_team_members << pt.team_member
      end
    end
    return relevant_team_members.size
  end
end

#Query Q7***************************************************************************************************************
#Scan all documents and return their ids
def query_7
  document_ids = []
  documents = Perpetuity[Document].all.to_a
  documents.each do |doc|
    document_ids << doc.id
  end
  #puts document_ids.join(', ')
  return document_ids.size

end

#Query Q8: ad-hoc join**************************************************************************************************
#Find all pairs of Legal_contracts and documents where the legal_contract_id in the document matches the id of the
#legal_contract. Also, return a count of the number of such pairs encountered.

def query_8
#no joins available
 contracts = Perpetuity[LegalContract].all.to_a
 documents = Perpetuity[Document].all.to_a
 Perpetuity[LegalContract].load_association! contracts, :project
  all_relevant_docs = []
  all_relevant_docs_count = 0
  contracts.each do |contract|
    pairs = Perpetuity[Document].select {|doc| doc.contract_id == contract.id }
    all_relevant_docs << pairs
    all_relevant_docs_count +=pairs.to_a.count
    #require 'debugger'; debugger
  end
  return all_relevant_docs_count
end
#STRUCTURAL MODIFICATIONS

#Structural Modification 1: Insert**************************************************************************************
#Create five new projects, which includes creating a number of new documents (100 in the small configuration, 1000 in
#the large, and five new legal_contract objects) and insert them into the database by installing references to these
# projects into 10 randomly team_member objects.
def modification_1_insert
  projects =[]
  5.times do
     proj = Project.new
     proj.budget = 300000.0
     proj.delivery_deadline = '2015-02-12'
     proj.status = "Planning"
     Perpetuity[Project].insert proj
    projects << proj
  end

  documents = []
  20.times do
    projects.each do |project|
      doc = Document.new
      doc.project = project
      doc.doc_type = "drawing"
      doc.doc_name = "The first floor plans"
      doc.revision_number = 3
      doc.revision_date = '2014-07-12'

      Perpetuity[Document].insert doc
      documents << doc
    end
  end

  projects.each do |project|
    contract = LegalContract.new
    contract.project = project
    contract.title = "SLA"
    contract.signed_on = '2013-04-02'
    contract.revised_on = '2013-12-12'
    contract.copy_stored = 'electronic version'

    Perpetuity[LegalContract].insert contract
  end
  return projects
end
#Structural Modification 2: Delete**************************************************************************************
#Delete the five newly created projects (and all of their associated documents and legal_contract objects).
def modification_2_deletion
  projects = modification_1_insert
  document_mapper = Perpetuity[Document]
  documents = document_mapper.all.to_a
  document_mapper.load_association! documents, :projects
  contract_mapper = Perpetuity[LegalContract]
  contracts = contract_mapper.all.to_a
  contract_mapper.load_association! contracts, :projects

  projects.each do |project|
    ds = document_mapper.select{|document| document.project.id == project.id}
    ds.each do |doc|
      document_mapper.delete doc
    end

    lc = contract_mapper.select{|contract| contract.project.id == project.id}
    lc.each do |lcon|
      contract_mapper.delete lcon
    end

    Perpetuity[Project].delete project
  end

 return "deleted"
end

#puts traversal_1
#puts traversal_2a
#puts traversal_2b
#puts traversal_2c
Benchmark.bm do |x|
  x.report("DataMapper#traversal_8 \n") do
    puts traversal_8
  end
  x.report("DataMapper#traversal_9 \n") do
    puts traversal_9
  end

end
