module RedminePirateHelpdesk
  module JournalPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        alias_method_chain :recipients, :pirate_helpdesk
        alias_method_chain :watcher_recipients, :pirate_helpdesk
      end
    end
    
    module InstanceMethods
      private
      def recipients_with_pirate_helpdesk
        recipient_addresses = recipients_without_pirate_helpdesk
        recipient_addresses - mail_recipients.map(&:address)
      end
      def watcher_recipients_with_pirate_helpdesk
        w_recipient_addresses = watcher_recipients_without_pirate_helpdesk
        w_recipient_addresses - mail_recipients.map(&:address)
      end
      
    end # module InstanceMethods
  end # module JournalPatch
end # module RedminePirateHelpdesk

# Add module to Journal class
Journal.send(:include, RedminePirateHelpdesk::JournalPatch)
