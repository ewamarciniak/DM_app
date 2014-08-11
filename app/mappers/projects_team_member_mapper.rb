Perpetuity.generate_mapper_for ProjectsTeamMember do

  attribute :project
  attribute :team_member

  index :project
  index :team_member
end