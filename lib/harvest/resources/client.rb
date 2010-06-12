module Harvest
  module Resources
    class Client < Harvest::HarvestResource
      include Harvest::Plugins::Toggleable

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
