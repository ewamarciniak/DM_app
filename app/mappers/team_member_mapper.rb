Perpetuity.generate_mapper_for TeamMember do
  attribute :team, type: String
  attribute :experience_level, type: String
  attribute :qualification, type: String
  attribute :lead, type: false
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'
end