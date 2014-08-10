class LegalContract
  include Perpetuity::RailsModel
  attr_accessor :copy_stored, :revised_on, :signed_on, :id, :created_at, :updated_at, :project, :title
end
