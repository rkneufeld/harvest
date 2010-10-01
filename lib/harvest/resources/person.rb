module Harvest
  module Resources
    class Person < Harvest::HarvestResource
      include Harvest::Plugins::Toggleable

      self.element_name = "person"
      
      has_many :entries
      has_many :expenses
      
      # Find all entries for the given person;
      # options[:from] and options[:to] are required;
      # include options[:user_id] to limit by a specific project.
      def entries(options={})
        return @entries if @entries and options == {} 
        validate_options(options)
        @entries = Harvest::Resources::Entry.find(:all, :conditions => {:person_id => self.id}, :params => format_params(options))
      end
      
      def expenses(options={})
        return @expenses if @expenses and options == {}
        validate_options(options)
        @expenses = Harvest::Resources::Expense.find(:all, :conditions => {:person_id => self.id}, :params => format_params(options))
      end
      
      def name
        "#{self.first_name} #{self.last_name}"
      end
      
      private
      
        def validate_options(options)
          if [:from, :to].any? {|key| !options[key].respond_to?(:strftime) }
            raise ArgumentError, "Must specify :from and :to as dates."
          end
          
          if options[:from] > options[:to]
            raise ArgumentError, ":start must precede :end."
          end
        
        end
        def format_params(options)
          ops = { :from => options[:from].strftime("%Y%m%d"),
                  :to   => options[:to].strftime("%Y%m%d")}
          ops[:project_id] = options[:project_id] if options[:project_id]
          return ops
        end
      
    end
  end
end