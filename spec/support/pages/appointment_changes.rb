module Pages
  class AppointmentChanges < Base
    set_url '/appointments/{id}/changes'

    section :changes_table, '.t-changes-table' do
      elements :change_rows, '.t-change-row'
    end
  end
end
