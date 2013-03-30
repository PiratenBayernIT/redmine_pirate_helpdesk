# Return true if user is authorized to send a mail via the "helpdesk system"
def mail_allowed?(project)
  User.current.allowed_to?(:pirate_helpdesk_send_mail, project)
end


def author_name(author)
  if author.firstname and author.lastname
    "#{author.firstname} #{author.lastname}"
  else
    author.mail
  end
end
  
  
def mailto_link(issue, author, body, linktext="")
  image = content_tag('img', linktext, 
    :src => '/plugin_assets/redmine_pirate_helpdesk/images/email.png', 
    :title => 'Per Mail antworten',
    :style => 'vertical-align: bottom; padding-right: 5px;') 
            
  mail_to author.mail, image,
   :subject => "Re: #{issue.subject} [\##{issue.id}]",
   :cc => 'redmine@piratenpartei-bayern.de',
   :body => body
end
  
  
def quote_text(text)
(text.split("\n").map { |l| ">" + l }).join("\n")
end
  
  
class HookListener < Redmine::Hook::ViewListener
  
  def controller_issues_new_after_save(context={})
    Rails.logger.info("###4")
    issue = context[:issue]
    custom_field = CustomField.find_by_name('Absender-Mail')
    custom_value = CustomValue.find(
      :first,
      :conditions => ["customized_id = ? AND custom_field_id = ?", issue.id, custom_field.id]
    )
    if not custom_value
      return
    end
    custom_value.value = issue.author.mail
    custom_value.save()
  end

  def view_issues_show_description_contextual_links(context={})
    if not mail_allowed?(context[:project])
      Rails.logger.info("### not authorize_for")
      return ""
    end
    issue = context[:issue]
    author = issue.author
    body = author_name(author) + " schrieb:\n"
    body << quote_text(issue.description)
    return mailto_link(issue, author, body, 'Mailantwort')
  end
  
  def helper_journals_links(context={})
    journal = context[:journal]
    if journal.journalized_type != "Issue" or journal.notes.empty? \
        or not mail_allowed?(context[:project])
      return ""
    end
    author = journal.user
    body = author_name(author) + " schrieb:\n\n"
    body << quote_text(journal.notes)
    context[:links] << mailto_link(context[:issue], author, body)
  end
  
end