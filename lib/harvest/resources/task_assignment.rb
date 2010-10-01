# This class is accessed by an instance of Project.
module Harvest
  module Resources
    class TaskAssignment < Harvest::HarvestResource
      self.element_name = "task_assignment"
      
      when_condition :project_id, :from => "/projects/:project_id/task_assignments"
      
    end
  end
end