module Pages
  class Search < SitePrism::Page
    set_url '/appointments/search'

    element :q,          '.t-q'
    element :date_range, '.t-date-range'
    element :search,     '.t-search'

    sections :results, '.t-result' do
      element :id, '.t-id'
    end
  end
end
