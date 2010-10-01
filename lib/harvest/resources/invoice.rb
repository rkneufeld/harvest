require 'csv'
module Harvest
  module Resources
    class Invoice < Harvest::HarvestResource
      self.element_name = 'invoice'

      has_many :messages
      has_many :payments

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
        
        if defined? CSV::Reader
          CSV::Reader.parse(csv_line_items) do |row|
            if headers
              headers = row
            else
              entry = {}
              row.each_with_index{|c,i|entry[headers[i]] = c}
              entries << entry
            end
          end
        else 
          rows = CSV.parse(csv_line_items)
          rows[1..-1].each do |row| 
            entry = {}
            row.each_with_index do |c,i|
              entry[rows[0][i]] = c
            end
            entries << entry
          end
        end
        entries
      end

      def balance
        due_amount
      end
      
      def paid_amount
        amount - due_amount
      end
      
      def sent?
        not state == 'draft'
      end
      
      def late?
        (not paid?) and (Time.now > due_at)
      end
            
      def paid?
        state == 'paid' || balance <= 0
      end
      
      def paid_in_full_payment
        full = amount
        payments.each do |payment|
          full -= payment.amount
          return payment if full <= 0
        end
        
        nil
      end
      
      def paid_at
        paid_in_full_payment ? paid_in_full_payment.paid_at : nil
      end

      def messages(refresh = false)
        @messages = nil if refresh
        @messages ||= InvoiceMessage.find(:all, :from => "/invoices/#{self.id}/messages")
      end

      def payments(refresh = false)
        @payments = nil if refresh
        @payments ||= InvoiceMessage.find(:all, :from => "/invoices/#{self.id}/payments")
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
