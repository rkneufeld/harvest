# This class is accessed by an instance of Project.
module Harvest
  module Resources
    class UserAssignment < Harvest::HarvestResource
      self.element_name = "user_assignment"
      
      when_condition :project_id, :from => "/projects/:project_id/user_assignments"
    end
  end
end