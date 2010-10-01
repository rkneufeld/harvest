# The entry resource is never accessed directly;
# rather, it is manipulated through an instance
# of Project or Person.
module Harvest
  module Resources
    class Entry < Harvest::HarvestResource
      belongs_to :task
      belongs_to :person, :foreign_key => :user_id

      when_condition :project_id, :from => "/projects/:project_id/entries"
      when_condition :person_id, :from => "/people/:person_id/entries"

      self.element_name = "entry"

      def person(refresh = false)
        @person = nil if refresh
        @person ||= Harvest::Resources::Person.find(self.user_id)
      end

      def person=(person)
        @person = person
      end
      
      def task(refresh = false)
        @task = nil if refresh
        @task ||= Harvest::Resources::Task.find(self.task_id)
      end
      
      def task=(task)
        @task = task
      end                  
    end
  end
end