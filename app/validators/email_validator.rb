class EmailValidator < ActiveModel::EachValidator
  VALID_REGEX = /.+@.+\..+/

  def validate_each(record, attribute, value)
    return unless value.present?

    if invalid_format?(value) || trailing_dot_in_username?(value) # rubocop:disable Style/GuardClause
      record.errors.add(attribute, :invalid, value: value)
    end
  end

  private

  def invalid_format?(value)
    value !~ VALID_REGEX
  end

  def trailing_dot_in_username?(value)
    value.split('@').first.ends_with?('.')
  end
end
