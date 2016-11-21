module BreadcrumbHelper
  def breadcrumb_part_for_previous_page
    content_tag(:li) do
      content_tag(:a, href: previous_page_path) do
        previous_page_title
      end
    end
  end

  private

  def previous_action
    session[:previous_action].to_s
  end

  def previous_controller
    session[:previous_controller].to_s
  end

  def previous_page_path
    url_for(controller: previous_controller, action: previous_action)
  rescue ActionController::UrlGenerationError
    search_appointments_path
  end

  def previous_page_title
    case "#{previous_controller}##{previous_action}"
    when 'activities#index'
      'My activity'
    when 'my_appointments#show'
      'My appointments'
    when 'company_calendars#show'
      'Company'
    else
      'Search'
    end
  end
end
