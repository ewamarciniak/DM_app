Perpetuity.generate_mapper_for Document do

  attribute :project
  attribute :doc_type, type: String
  attribute :doc_name, type: String
  attribute :revision_number, type: Integer
  attribute :revision_date, type: Time
  attribute :created_at, type: Time
  attribute :updated_at, type: Time

  index :project
end