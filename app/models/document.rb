class Document
  include Perpetuity::RailsModel
  attr_accessor :doc_type, :revision_number, :revision_date, :id, :created_at, :updated_at, :project, :doc_name, :contract_id

end
