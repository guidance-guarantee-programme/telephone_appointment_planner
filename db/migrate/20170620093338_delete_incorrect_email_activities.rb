class DeleteIncorrectEmailActivities < ActiveRecord::Migration[5.1]
  def up
    activities = CustomerUpdateActivity
      .joins(:appointment)
      .where(message: CustomerUpdateActivity::CONFIRMED_MESSAGE)
      .where(appointments: { email: '' })

    say "Deleting #{activities.count} incorrectly created activities"

    activities.delete_all
  end

  def down
    # noop
  end
end
