module CompaniesHelper

  def team_members_present?(company)
    team_members = Perpetuity[Person].select {| person | person.company.id == company.id && person.profile_type == "TeamMember"}
    team_members.any?
  end
end
