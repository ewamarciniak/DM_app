module TeamMembersHelper

  def is_a_lead?(teammember)
    teammember.lead ? "yes" : "no"
  end

  def team_members_projects?(tm)
    project_team_members = Perpetuity[ProjectsTeamMember].select{ |ptm| ptm.team_member.id == tm.id }
    project_team_members.any?
  end
end
