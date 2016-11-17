module DateOfBirthHelper
  def field_with_errors_wrapper(form, field, klass)
    error_class = form.object.errors[field].any? ? "field_with_errors #{klass}" : klass
    content_tag(:div, class: error_class) do
      yield
    end
  end
end
