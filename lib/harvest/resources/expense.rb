module Harvest
  module Resources
    class Expense < Harvest::HarvestResource
      self.element_name = "expense"
      
      when_condition :person_id, :from => "/people/:person_id/expenses"        
    end
  end
end