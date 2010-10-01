module Harvest
  # This is the base class from which all resource
  # classes inherit. Site and authentication params
  # are loaded into this class when a Harvest::Base
  # object is initialized.
  class HarvestResource < ActiveResource::Base
    include ActiveResourceThrottle
    include Harvest::Plugins::ActiveResourceInheritableHeaders
    
    class_attribute :__associations
    self.__associations = {}
    def self.has_one(name, options = {})
      self.__associations = __associations.merge(name => [:has_one, options])
    end
    
    def self.has_many(name, options = {})
      self.__associations = __associations.merge(name => [:has_many, options])
    end
    
    def self.belongs_to(name, options = {})
      self.__associations = __associations.merge(name => [:belongs_to, options])
    end
    
    ###CRZ - does not support more than one key at a time
    class_attribute :__maps
    self.__maps = {}
    def self.when_condition(field_given, options)
      self.__maps = __maps.merge(field_given => options)
    end
    
    # override find to implement eager loading :include with caching to avoid the very expensive REST requests.
    ### CRZ - only one level of eager loading supported; should pull in AR module to parse same depth structure
    def self.find(*arguments)
      options = {}
      options = arguments.last if arguments.last.is_a? Hash
      includes = arguments.last.delete(:include) if arguments.last.is_a? Hash
      if conditions = options.delete(:conditions)
        self.__maps.each do |key, map_options|
          if path = map_options[:from]
            arguments.last.merge!(:from => self.parse_path(path, key, conditions[key.to_sym])) if conditions.key?(key.to_sym)
          end
        end
      end
      
      records = super(*arguments)
      
      Array(includes).compact.each do |name|
        fk_name = ((a = self.__associations[name.to_sym]) && a[1][:foreign_key]) || "#{name.to_s}_id".to_sym
        grouped_records = Array(records).group_by {|x| x.send(fk_name) }
        grouped_records.each do |fk, group|
          associated_record = group.first.send(name.to_sym)
          group[1..-1].each do |record|
            record.send("#{name}=", associated_record.dup)
          end
        end
      end if includes
      
      records
    end
    
    # The harvest api will block requests in excess
    # of 40 / 15 seconds. Adds a throttle (with cautious settings). 
    # Throttle feature provided by activeresource_throttle gem.
    self.throttle(:requests => 30, :interval => 15, :sleep_interval => 60)
    
    private
    ###CRZ merge this from the rails router...and support multiple keys
    def self.parse_path(path, key, value)
      path.gsub(/:#{key}/, value.to_s)
    end
  end
end
