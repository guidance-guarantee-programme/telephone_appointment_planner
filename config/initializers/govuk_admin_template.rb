GovukAdminTemplate.environment_style = Rails.env.staging? ? 'preview' : ENV['RAILS_ENV']
GovukAdminTemplate.environment_label = Rails.env.titleize

GovukAdminTemplate.configure do |c|
  c.app_title = 'Telephone Appointment Planner'
  c.show_flash = true
  c.show_signout = true
end
