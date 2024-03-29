module DateOfBirthHelper
  def field_with_errors_wrapper(form, field, klass, &block)
    error_class = form.object.errors[field].any? ? "field_with_errors #{klass}" : klass
    content_tag(:div, class: error_class, &block)
  end
end
