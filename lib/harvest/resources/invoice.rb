require 'csv'
module Harvest
  module Resources
    class Invoice < Harvest::HarvestResource
      self.element_name = 'invoice'

      def mark_as_closed
        message = InvoiceMessage.new
        message.attributes = { :invoice_id => self.id, :state => 'mark_as_closed' }
        message.save
      end

      def make_payment(options = {})
        payment = InvoicePayment.new
        payment.attributes = { :invoice_id => self.id, :amount => options[:amount], :notes => options[:notes], :paid_at => options[:paid_at] || Time.now.utc }
        payment.save
      end

      def parsed_line_items
        headers = nil
        entries = []
        CSV::Reader.parse(csv_line_items) do |row|
          unless headers
            headers = row
          else
            entry = {}
            row.each_with_index{|c,i|entry[headers[i]] = c}
            entries << entry
          end
        end
        entries
      end

      def messages
        InvoiceMessage.find(:all, :from => "/invoices/#{self.id}/messages")
      end

      def payments
        InvoiceMessage.find(:all, :from => "/invoices/#{self.id}/payments")
      end

      class << self
        def find_by_number number
          i = find(:all).find{|i|i.number.to_s == number.to_s}
          find(i.id) if i
        end
      end
    end
  end
end
