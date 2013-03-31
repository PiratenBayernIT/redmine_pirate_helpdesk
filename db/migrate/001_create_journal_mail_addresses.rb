class CreateJournalMailAddresses < ActiveRecord::Migration
  def change
    create_table :journal_mail_addresses do |t|
      t.belongs_to :journal
      t.string :address
      t.string :address_type
    end
  end
end
