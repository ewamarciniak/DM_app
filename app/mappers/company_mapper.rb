Perpetuity.generate_mapper_for Company do
  attribute :company_name, type: String
  attribute :reg_number, type: String
  attribute :phone_number, type: String
  attribute :fax_number, type: String
  attribute :address, embedded: true
  attribute :created_at, type: Time
  attribute :updated_at, type: Time
  index :address_id
end
