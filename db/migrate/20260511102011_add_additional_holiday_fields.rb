class AddAdditionalHolidayFields < ActiveRecord::Migration[8.1]
  def change
    add_column :holidays, :description, :string, null: false, default: ''
    add_column :holidays, :additional_information, :string, null: false, default: ''

    add_reference :holidays, :creator
  end
end
