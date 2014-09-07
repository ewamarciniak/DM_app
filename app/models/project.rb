class Project
  include Perpetuity::RailsModel
  attr_accessor :budget, :delivery_deadline, :status, :id, :created_at, :updated_at, :client

  def project_client
    "Client:" +  client.person.first_name + " " + client.person.last_name
  end

end
