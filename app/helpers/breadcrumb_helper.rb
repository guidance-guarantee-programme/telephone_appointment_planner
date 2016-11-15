module BreadcrumbHelper
  def breadcrumb_part_for_previous_page
    path, title = path_and_title_from_referer

    content_tag(:li) do
      content_tag(:a, href: path) do
        title
      end
    end
  end

  private

  def path_and_title_from_referer # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    if request_uri.start_with?(search_appointments_path)
      [request_uri, 'Search']
    elsif request_uri.start_with?(activities_path)
      [request_uri, 'My activity']
    elsif request_uri.start_with?(calendar_path)
      [request_uri, 'My appointments']
    elsif request_uri.start_with?(company_calendar_path)
      [request_uri, 'Company']
    elsif request_uri.start_with?(resource_calendar_path)
      [request_uri, 'Allocations']
    end
  end

  def request_uri
    @request_uri ||= URI.parse(request.referer).request_uri
  rescue URI::InvalidURIError
    search_appointments_path
  end
end
