class AddCompanyNameToAdsDepartment < ActiveRecord::Migration
  def change
    add_column :ads_departments, :company_name, :string
  end
end
