# The entry resource is never accessed directly;
# rather, it is manipulated through an instance
# of Project or Person.
module Harvest
  module Resources
    class Entry < Harvest::HarvestResource
      
      self.element_name = "entry"

      def people
        user_class = Harvest::Resources::Person.clone
        user_class.find @person_id
      end
      
      def tasks
        task_class = Harvest::Resources::Task.clone
        task_class.find @task_id
      end
      
      class << self
        
        def project_id=(id)
          @project_id = id
          self.site = self.site + "/projects/#{@project_id}"
        end
        
        def project_id
          @project_id
        end
        
        def person_id=(id)
          @person_id = id
          self.site = self.site + "/people/#{@person_id}"
        end
        
        def person_id
          @person_id
        end
        
        
        def task_id=(id)
          @task_id = id
          self.site = self.site + "/tasks/#{@task_id}"
        end
        
        def task_id
          @task_id
        end
        
      end
                  
    end
  end
end