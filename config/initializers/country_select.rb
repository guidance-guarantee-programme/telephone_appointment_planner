CountrySelect::FORMATS[:default] = lambda do |country|
  "#{country.translations[I18n.locale.to_s]} (+#{country.country_code})"
end
