class AasmStateToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :aasm_state, :string, null: false
    add_index :shipments, :aasm_state
  end
end
