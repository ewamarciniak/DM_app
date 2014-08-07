Perpetuity.generate_mapper_for Document do
  attribute :project, embedded: true
  attribute :doc_type, type: String
  attribute :doc_name, type: String
  attribute :pref_method_of_contact, type: String
  attribute :pref_hours_of_contact, type: String
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'

  index :project_id
end