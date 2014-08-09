class Client
  include Perpetuity::RailsModel
  attr_accessor :pref_hours_of_contact, :pref_method_of_contact, :id, :created_at, :updated_at

  def person_name
    person.name_and_company
  end

end