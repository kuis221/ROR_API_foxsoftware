class AdminNotesUser < ActiveRecord::Migration
  def change
    add_column :users, :admin_notes, :string
  end
end
