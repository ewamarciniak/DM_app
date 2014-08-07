Perpetuity.generate_mapper_for Client do
  attribute :pref_method_of_contact, type: String
  attribute :pref_hours_of_contact, type: String
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'
end