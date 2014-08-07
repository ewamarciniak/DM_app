Perpetuity.generate_mapper_for LegalContract do
  attribute :project, embedded: true
  attribute :title, type: String
  attribute :signed_on, type: Date
  attribute :revised_on, type: Date
  attribute :copy_stored, type: String
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'

  index :project_id
end