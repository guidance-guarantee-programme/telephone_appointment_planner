module Pages
  class Search < Base
    set_url '/appointments/search'

    element :q,          '.t-q'
    element :date_range, '.t-date-range'
    element :search,     '.t-search'
    element :rebook,     '.t-rebook'

    sections :results, '.t-result' do
      element :id, '.t-id'
      element :name, '.t-name'
    end
  end
end
