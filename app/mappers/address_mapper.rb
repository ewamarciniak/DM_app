Perpetuity.generate_mapper_for Address do
  attribute :line1, type: String
  attribute :line2, type: String
  attribute :postcode, type: String
  attribute :city, type: String
  attribute :county, type: String
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'
end