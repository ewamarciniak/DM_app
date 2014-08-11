class Project
  include Perpetuity::RailsModel
  attr_accessor :budget, :delivery_deadline, :status, :id, :created_at, :updated_at
end
