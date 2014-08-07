Perpetuity.generate_mapper_for Person do
  attribute :first_name, type: String
  attribute :last_name, type: String
  attribute :phone_number, type: String
  attribute :email, type: String
  attribute :company, embedded: true
  attribute :profile, embedded: true
  attribute :profile_type, type: String
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'

  index :profile_id
end