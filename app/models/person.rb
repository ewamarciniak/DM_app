class Person
  include Perpetuity::RailsModel
  attr_accessor :email, :first_name, :last_name, :phone_number, :profile_type, :profile, :id, :created_at,
                :updated_at, :company
  def name
    self.first_name + ' ' + self.last_name
  end

  def person_company
    Perpetuity[Person].load_association! self, :company
    self.company
  end

  def load_company
    Perpetuity[Person].load_association! self, :company
    self.company
  end
end
