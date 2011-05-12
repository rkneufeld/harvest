module Harvest
  module Resources
    class Client < Harvest::HarvestResource
      include Harvest::Plugins::Toggleable

      def build_contact(attributes = {})
        contact = Contact.new
        contact.attributes = attributes.merge({'client_id' => self.id})
        return contact
      end

      def contacts(refresh = false)
        if not refresh and @contacts
          @contacts
        else
           page, @contacts = 1, []
           begin
             set = Contact.find(:all, :params => {:client => self.id, :page => page})
            puts "Found #{set.length.to_s} contacts" if Harvest::Base.debug_level == 2
            @contacts += set
            page +=1
          end while set.length == 50
        end
        @contacts
      end

      def build_invoice(attributes = {})
        invoice = Invoice.new
        invoice.attributes = attributes.merge({'client_id' => self.id})
        return invoice
      end

      def invoices(refresh = false)
        if not refresh and @invoices
          @invoices
        else
          page, @invoices = 1, []
          begin
            set = Invoice.find(:all, :params => {:client => self.id, :page => page })
            puts "Found #{set.length.to_s} invoices" if Harvest::Base.debug_level == 2
            @invoices += set
            page +=1
          end while set.length == 50
          @invoices
        end
      end

      def balance
        invoices.select {|invoice| invoice.sent? }.inject(0) {|total, invoice| total + invoice.balance}
      end
      
      def invoiced_amount
        invoices.select {|invoice| invoice.sent? }.inject(0) {|total, invoice| total + invoice.amount}
      end
      
      def paid_amount
        invoices.select {|invoice| invoice.sent? }.inject(0) {|total, invoice| total + invoice.paid_amount}
      end
    end
  end
end
