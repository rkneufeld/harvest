module Harvest
  class Base
    @debug_level = 0

    def self.debug_level
      @debug_level
    end
    
    def self.debug_level=(debug_level)
      raise ArgumentError, "debug level must be an integer" unless debug_level == debug_level.to_i

      return @debug_level if @debug_level == debug_level

      @debug_level = debug_level.to_i

      ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber

      case @debug_level
      when 0 then
      when 1 then
        @subscriber = ActiveSupport::Notifications.subscribe(/request.active_resource/) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          puts "-- HARVEST #{event.payload[:method].to_s.upcase} #{event.payload[:request_uri]}, #{event.payload[:result].andand.code}: #{event.payload[:result].andand.message}"
        end
      else
        @subscriber = ActiveSupport::Notifications.subscribe(/request.active_resource/) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          puts "-- HARVEST #{event.payload[:method].to_s.upcase} #{event.payload[:request_uri]}, #{event.payload[:result].andand.code}: #{event.payload[:result].andand.message}"
          puts event.payload[:result].body + "\n"
        end
      end
      
      @debug_level
    end
   
    # Requires a sub_domain, email, and password.
    # Specifying headers is optional, but useful for setting a user agent.
    def initialize(options={})
      options.assert_required_keys(:email, :password, :sub_domain)
      @email        = options[:email]
      @password     = options[:password]
      @sub_domain   = options[:sub_domain]
      @headers      = options[:headers]
      @ssl          = options[:ssl]
      configure_base_resource
    end
    
    # Below is a series of proxies allowing for easy
    # access to the various resources.
    
    # Clients
    def clients
      Harvest::Resources::Client
    end

    # Contacts
    def contacts
      Harvest::Resources::Contact
    end
    
    # Expenses.
    def expenses
      Harvest::Resources::Expense
    end
    
    # Expense categories.
    def expense_categories
      Harvest::Resources::ExpenseCategory
    end
    
    # People.
    # Also provides access to time entries.
    def people
      Harvest::Resources::Person
    end
    
    # Projects.
    # Provides access to the assigned users and tasks
    # along with reports for entries on the project.
    def projects
      Harvest::Resources::Project
    end
    
    # Tasks.
    def tasks
      Harvest::Resources::Task
    end

    # Invoices
    def invoices
      Harvest::Resources::Invoice
    end

    # Invoice Messages
    def invoice_messages
      Harvest::Resources::InvoiceMessage
    end

    private
    
      # Configure resource base class so that 
      # inherited classes can access the api.
      def configure_base_resource
        HarvestResource.site     = "http#{'s' if @ssl}://#{@sub_domain}.#{Harvest::ApiDomain}"
        HarvestResource.user     = @email
        HarvestResource.password = @password
        HarvestResource.headers.update(@headers) if @headers.is_a?(Hash)
        load_resources
      end
      
      # Load the classes representing the various resources.
      def load_resources
        resource_path = File.join(File.dirname(__FILE__), "resources")
        Harvest.load_all_ruby_files_from_path(resource_path)
      end
                
  end
end
