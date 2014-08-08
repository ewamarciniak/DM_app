class Address
  include Perpetuity::RailsModel

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
  attr_accessor :name, :city, :county, :line1, :line2, :postcode
  attr_reader   :errors

  POSTCODES =["1","2","3","4","5","6", "6W","7","8","9","10","11","12","13","14","15","16","17","18","20","22","24"]
  COUNTIES =["Antrim","Armagh","Carlow","Cavan","Clare","Cork","Derry","Donegal","Down"," Dublin","Fermanagh","Galway",
             "Kerry","Kildare","Kilkenny","Laois","Leitrim","Limerick","Longford","Louth","Mayo","Meath","Monaghan",
             "Offaly","Roscommon","Sligo","Tipperary","Tyrone","Waterford","Westmeath","Wexford","Wicklow"]

  def full_address
    optionals = [postcode, county, line2]
    n = 0
    optionals.each do |el|
      optionals[n] = el.blank? ? '' : (n==(optionals.size-1) ? el : el + ', ' )
      n+=1
    end

    line1 + ', ' + optionals[0] + city + ', ' + optionals[1] + optionals[2]
  end
end