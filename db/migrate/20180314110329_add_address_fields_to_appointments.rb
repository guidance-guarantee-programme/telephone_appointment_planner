class AddAddressFieldsToAppointments < ActiveRecord::Migration[5.1]
  def change
    with_options default: '', null: false do
      add_column :appointments, :address_line_one, :string
      add_column :appointments, :address_line_two, :string
      add_column :appointments, :address_line_three, :string
      add_column :appointments, :town, :string
      add_column :appointments, :county, :string
      add_column :appointments, :postcode, :string
    end
  end
end
