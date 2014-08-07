Perpetuity.generate_mapper_for Project do
  attribute :client, embedded: true
  attribute :budget, type: 'double precision'
  attribute :delivery_deadline, type: Date
  attribute :status, type: String
  attribute :created_at, type: 'timestamp without time zone'
  attribute :updated_at, type: 'timestamp without time zone'

  index :client_d
end