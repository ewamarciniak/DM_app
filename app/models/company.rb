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
    errors.add(:company_name, "cannot be blank.") if self.company_name = ""
  end

end
