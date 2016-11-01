module Pages
  class ReportCsv < SitePrism::Page
    def csv
      results = CSV.parse(page.body)
      results[0] = results[0].map(&:to_sym)
      results
    end

    def content_disposition
      page.response_headers['Content-Disposition']
    end
  end
end
