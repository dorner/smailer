module Smailer
  module Models
    class MailCampaign < ActiveRecord::Base
      class UnsubscribeMethods
        URL     = 1
        REPLY   = 2
        BOUNCED = 4
      end

      belongs_to :mailing_list
      has_many :queued_mails, :dependent => :destroy
      has_many :finished_mails

      validates_presence_of :mailing_list_id, :from
      validates_numericality_of :mailing_list_id, :unsubscribe_methods, :only_integer => true, :allow_nil => true
      validates_length_of :from, :subject, :maximum => 255, :allow_nil => true

      attr_accessible :mailing_list_id, :from, :subject, :body_html, :body_text 

      def add_unsubscribe_method(method)
        self.unsubscribe_methods = (self.unsubscribe_methods || 0) | method
      end

      def remove_unsubscribe_method(method)
        if has_unsubscribe_method?(method)
          self.unsubscribe_methods = (self.unsubscribe_methods || 0) ^ method
        end
      end

      def has_unsubscribe_method?(method)
        (unsubscribe_methods || 0) & method === method
      end

      def active_unsubscribe_methods
        self.class.unsubscribe_methods.reject do |method, method_name|
          not has_unsubscribe_method?(method)
        end
      end

      def name
        "Campaign ##{id} (#{mailing_list.name})"
      end

      def self.unsubscribe_methods
        methods = {}
        UnsubscribeMethods.constants.map do |method_name|
          methods[UnsubscribeMethods.const_get(method_name)] = method_name
        end

        methods
      end
    end
  end
end