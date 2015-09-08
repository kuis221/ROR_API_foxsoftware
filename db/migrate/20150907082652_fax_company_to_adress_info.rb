class FaxCompanyToAdressInfo < ActiveRecord::Migration
  def change
    add_column :address_infos, :fax, :string
    add_column :address_infos, :company_name, :string
  end
end
