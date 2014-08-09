class Document
  include Perpetuity::RailsModel
  attr_accessor :doc_type, :revision_number, :revision_date, :id, :created_at, :updated_at, :project, :doc_name

  def initialize attributes={}
    attributes.each do |attr, value|
      instance_variable_set "@#{attr}", value
    end

    if @revision_date.is_a? String
      @revision_date = Date.parse(@revision_date).to_date
    end
  end
end
