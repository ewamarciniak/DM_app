class Person
  include Perpetuity::RailsModel
  attr_accessor :email, :first_name, :last_name, :phone_number, :profile, :id, :created_at,
                :updated_at, :company
end
