# Redmine - project management software
# Copyright (C) 2006-2013  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)

class MailerTest < RedminePirateHelpdeskTestCase
  include Redmine::I18n
  include ActionDispatch::Assertions::SelectorAssertions
  fixtures :projects, :enabled_modules, :issues, :users, :members,
           :member_roles, :roles, :documents, :attachments, :news,
           :tokens, :journals, :journal_details, :changesets,
           :trackers, :projects_trackers,
           :issue_statuses, :enumerations, :messages, :boards, :repositories,
           :versions,
           :comments, 
           :journal_mail_addresses

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
  end

  
  def test_journal_mail_recipients_filtered_out
    journal = Journal.find(3)
    ma = JournalMailAddress.find(1)
    assert ma != nil
    assert Mailer.issue_edit(journal).deliver
    journal.mail_recipients.map(&:address).each do |a|
      assert !last_email.bcc.include?(a), a + " must not be included!"
    end
  end

  private

  def last_email
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    mail
  end

  def text_part
    last_email.parts.detect {|part| part.content_type.include?('text/plain')}
  end

  def html_part
    last_email.parts.detect {|part| part.content_type.include?('text/html')}
  end
end
