module Pages
  class OnlineReschedulingsSearch < Base
    set_url '/online_reschedulings'

    sections :results, '.t-result' do
      element :id, '.t-id'
      element :customer_name, '.t-name'
      element :previous_guider_name, '.t-previous-guider-name'
      element :appointment_date_time, '.t-appointment-date-time'
      element :rescheduled_date_time, '.t-rescheduled-date-time'
      element :processed, '.t-processed'
    end
  end
end
