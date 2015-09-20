class AddUserIdToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :user_id, :integer
  end
end
