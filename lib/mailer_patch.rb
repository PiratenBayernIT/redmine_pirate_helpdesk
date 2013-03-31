# not used atm

module RedminePirateHelpdesk
  module MailerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        #alias_method_chain :issue_edit, :pirate_helpdesk
      end
    end
    
    module InstanceMethods
      private
      #def issue_edit_with_pirate_helpdesk(journal)
      #  issue_edit_without_pirate_helpdesk(journal)
      #end
      
    end # module InstanceMethods
  end # module MailerPatch
end # module RedminPirateHelpdesk

# Add module to MailHandler class
Mailer.send(:include, RedminePirateHelpdesk::MailerPatch)
