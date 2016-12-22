class SetActivitiesMessageDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :activities, :message, ''
  end
end
