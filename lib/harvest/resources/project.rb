module Harvest
  module Resources
    # Supports the following:
    class Project < Harvest::HarvestResource
      include Harvest::Plugins::Toggleable
      
      self.element_name = "project"
      
      has_many :entries
      has_many :users
      has_many :tasks
      
      def users(options = {})
        @users ||= Harvest::Resources::UserAssignment.find(:all, :include => options[:include], :conditions => {:project_id => self.id})
      end
      
      def tasks(options = {})
        @tasks ||= Harvest::Resources::TaskAssignment.find(:all, :include => options[:include], :conditions => {:project_id => self.id})
      end
      
      # Find all entries for the given project;
      # options[:from] and options[:to] are required;
      # include options[:user_id] to limit by a specific user.
      #   
      def entries(options={})
        return @entries if @entries and options == {}
        validate_entries_options(options)
        @entries = Harvest::Resources::Entry.find(:all, :include => options[:include], :conditions => {:project_id => self.id}, :params => format_params(options))
      end
      
      private
      
        def validate_entries_options(options)
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
          ops[:user_id] = options[:user_id] if options[:user_id]
          return ops
        end
          
    end
  end
end