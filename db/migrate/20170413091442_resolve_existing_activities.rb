class ResolveExistingActivities < ActiveRecord::Migration[5.0]
  def up
    resolver = User.find_by(name: 'Ben Lovell')

    return unless resolver

    Activity
      .high_priority
      .unresolved
      .where('created_at < ?', Date.yesterday)
      .update_all(
        resolver_id: resolver.id,
        resolved_at: Time.zone.now
      )
  end

  def down
    # noop
  end
end
