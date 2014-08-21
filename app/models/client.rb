class Client
  include Perpetuity::RailsModel
  attr_accessor :pref_hours_of_contact, :pref_method_of_contact, :id, :created_at, :updated_at

  def person_name
    person.name_and_company
  end

  def person
    Perpetuity[Person].select { |person| person.profile.id == self.id}.to_a.first
  end
end