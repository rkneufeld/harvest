module Harvest
  module Resources
    class Task < Harvest::HarvestResource
      include Harvest::Plugins::Toggleable

      self.element_name = "task"
                  
    end
  end
end