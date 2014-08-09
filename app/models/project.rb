class Project
  include Perpetuity::RailsModel
  attr_accessor :budget, :delivery_deadline, :status, :id, :created_at, :updated_at

  def initialize attributes={}
    attributes.each do |attr, value|
      instance_variable_set "@#{attr}", value
    end

    if @delivery_deadline.is_a? String
      @delivery_deadline = Date.parse(@delivery_deadline).to_date
    end
  end
end
