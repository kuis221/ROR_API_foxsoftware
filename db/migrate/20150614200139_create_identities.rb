class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :uid, :provider, :token, :secret, :email, :avatar_url, :nickname, :first_name, :last_name
      t.datetime :expires_at
      t.timestamps null: false
    end
    add_index :identities, [:uid, :provider]
  end
end
