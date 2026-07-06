class HolidayMailerPreview < ActionMailer::Preview
  def block_digest # rubocop:disable Metrics/MethodLength
    HolidayMailer.block_digest(
      [
        OpenStruct.new(
          all_day: false,
          title: 'Tier 2 - Super Huddle',
          start_at: Time.zone.parse('2026-06-10 15:30'),
          end_at: Time.zone.parse('2026-06-10 16:30'),
          description: 'training',
          holiday_ids: '1,2,3'
        ),
        OpenStruct.new(
          all_day: true,
          title: 'Guider Conference',
          start_at: Time.zone.parse('2026-06-14 00:00'),
          end_at: Time.zone.parse('2026-06-15 23:59'),
          description: 'team_meeting',
          holiday_ids: '1,2,3'
        )
      ]
    )
  end
end
