class TeamMember
  include Perpetuity::RailsModel
  attr_accessor :experience_level, :lead, :qualification, :team, :id, :created_at, :updated_at

  def person
     Perpetuity[Person].select { |person| person.profile.id == self.id}.to_a.first
  end
end
