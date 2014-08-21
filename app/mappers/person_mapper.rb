Perpetuity.generate_mapper_for Person do
  attribute :first_name, type: String
  attribute :last_name, type: String
  attribute :phone_number, type: String
  attribute :email, type: String
  attribute :company
  attribute :profile
  attribute :profile_type, type: String
  attribute :created_at, type: Time
  attribute :updated_at, type: Time

  index :profile
  index :company
end