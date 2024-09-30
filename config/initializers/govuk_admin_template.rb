GovukAdminTemplate.environment_style = Rails.env.staging? ? 'preview' : ENV['RAILS_ENV']
GovukAdminTemplate.environment_label = ENV['PREVIEW_ENV'] ? 'Preview' : Rails.env.titleize

GovukAdminTemplate.configure do |c|
  c.app_title = 'Telephone Planner'
  c.show_flash = true
  c.show_signout = true
end
