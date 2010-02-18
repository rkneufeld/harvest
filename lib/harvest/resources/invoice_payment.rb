module Harvest
  module Resources
    class InvoicePayment < Harvest::HarvestResource
      def collection_path(options = {})
        "/invoices/#{self.attributes.delete(:invoice_id)}/payments.xml"
      end
    end
  end
end
