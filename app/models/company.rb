class Company
  include Perpetuity::RailsModel
  attr_accessor :company_name, :fax_number, :phone_number, :reg_number, :address, :id, :created_at, :updated_at

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def save
    validate!
    errors.empty? ? super : false
  end

  def validate!
    #place custom validations here e.g.
    errors.add(:name, "cannot be blank.") if self.name = ""
    errors.add(:number,"must be less than 7.") if self.number >= 7
  end
end
