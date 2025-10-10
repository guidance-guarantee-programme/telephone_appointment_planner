namespace :reschedules do
  desc 'Build online reschedules'
  task build: :environment do
    Appointment.where.not(previous_guider_id: nil).find_each do |appointment|
      audits = appointment
               .audits
               .where(action: 'update')
               .order(created_at: :desc)
               .select { |audit| audit.audited_changes.key?('online_rescheduling_reason') }

      audits.each do |audit|
        changes = audit.audited_changes

        next unless changes.key?('start_at') && changes.key?('guider_id') && changes.key?('rescheduled_at')

        previous_start_at  = changes['start_at'].first
        previous_guider_id = changes['guider_id'].first
        rescheduled_at     = changes['rescheduled_at'].last

        appointment.online_reschedules.find_or_create_by!(
          previous_guider_id:,
          previous_start_at:,
          created_at: rescheduled_at,
          updated_at: rescheduled_at
        )
      end
    end
  end
end
