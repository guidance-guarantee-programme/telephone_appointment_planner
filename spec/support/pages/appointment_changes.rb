module Pages
  class AppointmentChanges < Base
    set_url '/appointments/{id}/changes'

    section :changes_table, '.t-changes-table' do
      element :change_row, '.t-change-row'
    end
  end
end
