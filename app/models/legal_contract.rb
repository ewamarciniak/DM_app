class LegalContract
  include Perpetuity::RailsModel
  attr_accessor :copy_stored, :revised_on, :signed_on, :id, :created_at, :updated_at, :project, :title

  def initialize attributes={}
    attributes.each do |attr, value|
      instance_variable_set "@#{attr}", value
    end

    if @revised_on.is_a? String
      @revised_on = Date.parse(@revised_on).to_date
    end

    if @signed_on.is_a? String
      @signed_on = Date.parse(@signed_on).to_date
    end
  end
end
