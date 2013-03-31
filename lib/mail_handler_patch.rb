module RedminePirateHelpdesk
  module MailHandlerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        alias_method_chain :receive_issue, :pirate_helpdesk
        alias_method_chain :receive_issue_reply, :pirate_helpdesk
      end
    end
    
    def add_mail_adresses(journal, addresses, recipient_type)
      logger.info("###6")
      logger.info(addresses)
      logger.info(recipient_type)
      emission_address = Setting.mail_from.to_s.strip.downcase
      prepared_addresses = addresses.compact.uniq.collect {|a| a.strip.downcase}
      logger.info(prepared_addresses)
      (prepared_addresses.reject {|a| a == emission_address}).each do |address|
        journal.mail_recipients << JournalMailAddress.new(:address_type => recipient_type, :address => address)
      end
    end
        
    module InstanceMethods
      private
      def receive_issue_with_pirate_helpdesk
        issue = receive_issue_without_pirate_helpdesk
        ### patch for redmine_pirate_helpdesk to add sender mail to created tickets
        custom_field = CustomField.find_by_name('Absender-Mail')
        if custom_field
          custom_value = CustomValue.find(
            :first,
            :conditions => ["customized_id = ? AND custom_field_id = ?", issue.id, custom_field.id]
          )
          if custom_value
            custom_value.value = issue.author.mail
            custom_value.save()
          end
        end
        issue
      end
      
      def receive_issue_reply_with_pirate_helpdesk(issue_id, from_journal=nil)
        journal = receive_issue_reply_without_pirate_helpdesk(issue_id, from_journal)
        # save cc and to-addresses
        if @email.to
          add_mail_adresses(journal, @email.to, 'to')
        end
        if @email.cc
          add_mail_adresses(journal, @email.cc, 'cc')
        end
        journal
      end
      
    end # module InstanceMethods
  end # module MailHandlerPatch
end # module RedminPirateHelpdesk

# Add module to MailHandler class
MailHandler.send(:include, RedminePirateHelpdesk::MailHandlerPatch)
