Perpetuity.generate_mapper_for LegalContract do
  attribute :project, embedded: true
  attribute :title, type: String
  attribute :signed_on, type: Date
  attribute :revised_on, type: Date
  attribute :copy_stored, type: String
  attribute :created_at, type: Time
  attribute :updated_at, type: Time

  index :project_id
end