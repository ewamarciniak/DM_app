Perpetuity.generate_mapper_for Project do

  attribute :client, embedded: true
  attribute :budget, type: 'double precision'
  attribute :delivery_deadline, type: Time
  attribute :status, type: String
  attribute :created_at, type: Time
  attribute :updated_at, type: Time

  index :client_id
end