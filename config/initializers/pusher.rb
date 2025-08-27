Pusher.app_id = ENV.fetch('PUSHER_APP_ID') { 'pension_wise_tap' }
Pusher.key    = ENV.fetch('PUSHER_KEY')    { 'pusher_key' }
Pusher.secret = ENV.fetch('PUSHER_SECRET') { 'pusher_secret' }

require 'pusher-fake/support/base' if Rails.env.development? && !ENV['DISABLE_PUSHER_FAKE']
