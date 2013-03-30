require 'hook_listener'

Redmine::Plugin.register :redmine_pirate_helpdesk do
  name 'Redmine Pirate Helpdesk plugin'
  author 'Author name'
  description 'Plugin for a simple pirate helpdesk system'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  
  
project_module :pirate_helpdesk do
  permission :pirate_helpdesk_send_mail, {}
end
end
