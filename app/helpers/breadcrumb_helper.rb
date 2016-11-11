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

  def path_and_title_from_referer
    if request_uri.start_with?(search_appointments_path)
      [request_uri, 'Search']
    elsif request.start_with?(activities_path)
      [request_uri, 'My activity']
    elsif request_uri.start_with?(calendar_path)
      [request_uri, 'My appointments']
    end
  end

  def request_uri
    @request_uri ||= URI.parse(request.referer).request_uri
  rescue URI::InvalidURIError
    search_appointments_path
  end
end
