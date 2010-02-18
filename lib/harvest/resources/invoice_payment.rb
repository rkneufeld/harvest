module Harvest
  module Resources
    class InvoicePayment < Harvest::HarvestResource
      self.element_name = "payment"
      def collection_path(options = {})
        "/invoices/#{self.attributes.delete(:invoice_id)}/payments.xml"
      end
    end
  end
end
