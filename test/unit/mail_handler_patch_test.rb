# encoding: utf-8
#
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

class MailHandlerPatchTest < RedminePirateHelpdeskTestCase
  
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/mail_handler'
  
  fixtures :users, :projects, :enabled_modules, :roles,
           :members, :member_roles, :users,
           :issues, :issue_statuses,
           :workflows, :trackers, :projects_trackers,
           :versions, :enumerations, :issue_categories


  def setup
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = Redmine::Notifiable.all.collect(&:name)
  end

  def teardown
    Setting.clear_cache
  end

  # added
  def test_update_issue_with_cc
    journal = submit_email('ticket_reply_with_cc.eml')
    assert_equal 2, journal.mail_recipients.size
    to_recipient = journal.mail_recipients[0]
    cc_recipient = journal.mail_recipients[1]
    assert_equal 'to', to_recipient.address_type
    assert_equal 'cc', cc_recipient.address_type
    assert_equal 'dlopper@somenet.foo', to_recipient.address
    assert_equal 'redmine@somenet.foo', cc_recipient.address
    assert_equal journal.id, to_recipient.journal_id
    assert_equal journal.id, cc_recipient.journal_id
    assert journal.is_a?(Journal)
    assert_equal User.find_by_login('jsmith'), journal.user
    assert_equal Issue.find(2), journal.journalized
    assert_match /This is reply/, journal.notes
    assert_equal false, journal.private_notes
    assert_equal 'Feature request', journal.issue.tracker.name
  end
  
  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    yield raw if block_given?
    MailHandler.receive(raw, options)
  end

  def assert_issue_created(issue)
    assert issue.is_a?(Issue)
    assert !issue.new_record?
    issue.reload
  end
end
