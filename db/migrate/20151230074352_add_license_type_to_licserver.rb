class AddLicenseTypeToLicserver < ActiveRecord::Migration
  def change
    add_reference :licservers, :license_type, index: true, default: LicenseType.first.id
  end
end
