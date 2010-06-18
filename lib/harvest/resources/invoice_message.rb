module Harvest
  module Resources
    class InvoiceMessage < Harvest::HarvestResource
      def collection_path(options = {})
        if self.attributes.has_key?(:state)
          "/invoices/#{self.attributes.delete(:invoice_id)}/messages/#{self.attributes.delete(:state)}.xml"
        else
          "/invoices/#{self.attributes.delete(:invoice_id)}/messages.xml"
        end
      end
      
      def marked_sent_manually?
        full_recipient_list.nil?
      end
    end
  end
end
