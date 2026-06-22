# frozen_string_literal: true

# No more that 20 requests per minute per ip
limit = ENV.fetch('ATTACK_RATE_LIMIT', 20).to_i
period = ENV.fetch('ATTACK_RATE_PERIOD', 60).to_i
throttle_off = ActiveModel::Type::Boolean.new.cast(ENV.fetch('ATTACK_RATE_THROTTLE_OFF', Rails.env.development? || Rails.env.test?))

unless throttle_off
  Rack::Attack.throttle('throttle catalog requests by ip', limit: limit, period: period) do |req|
    if req.path.starts_with?('/catalog') # rubocop:disable Style/IfUnlessModifier
      req.remote_ip
    end
  end

  FileUtils.mkdir_p(Rails.root.join('log', 'rack_attack'))
  throttle_logger = ActiveSupport::Logger.new(
    Rails.root.join('log', 'rack_attack', 'throttled_requests.log'),
    'daily'
  )
  throttle_logger.formatter = proc do |_severity, datetime, _progname, msg|
    "#{datetime.iso8601} #{msg}\n"
  end

  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    # Use ActionDispatch::Request's #remote_ip to prevent IP spoofing
    # https://github.com/rack/rack-attack/issues/145
    origin_ip = req.remote_ip

    throttle_logger.info(
      "#{req.env['rack.attack.match_type']} " \
        "#{origin_ip} " \
        "#{req.env['rack.attack.match_data'][:count]}/#{req.env['rack.attack.match_data'][:limit]} " \
        "#{req.env['rack.attack.match_data'][:period]}s " \
        "#{req.request_method} " \
        "#{req.fullpath}"
    )
  end

  #########################  
  # Custom blocklist rules
  #########################
  blocked_logger = ActiveSupport::Logger.new(
    Rails.root.join('log', 'rack_attack', 'blocked_requests.log'),
    'daily'
  )

  Rack::Attack.blocklist('block inhuman number of search params in catalog requests') do |req|
    # Requests are blocked if the return value is truthy
    if req.path.starts_with?('/catalog')
      # Use ActionDispatch::Request's #remote_ip to prevent IP spoofing
      # https://github.com/rack/rack-attack/issues/145
      origin_ip = req.remote_ip
      if URI.parse(req.url).query
        search_params = URI.decode_www_form(URI.parse(req.url).query)
                           .reject { |param| param.first.include?("year_range_isim") }
        if search_params.count > 6 || (search_params.count > 4 && req.referer =~ /#{req.base_url}?(\:\d+)?(\/)/)
          blocked_logger.info(
            "#{origin_ip} " \
              "#{req.get_header('HTTP_USER_AGENT')}"
          )
          true
        end
      end
    else
      # Apple keeps spamming the stats page even when we tell it not to
      req.path.include?("/stats")
    end
  end

  Rack::Attack.safelist("authenticated and UVic users") do |request|
    # Always allow logged-in users
    if request.env['warden'].authenticated?(:user)
      true
    else
      # Always allow users on campus
      origin_ip = request.remote_ip
      begin
        Hydra::IpBasedGroups.groups.find { |group| group.name == "uvic" }.include_ip? origin_ip
      rescue IPAddr::InvalidAddressError
        false
      end
    end
  end

  Rack::Attack.safelist("whitelisted crawlers like search engines") do |req|
    if req.path.starts_with?('/catalog')
      origin_ip = req.get_header('HTTP_X_FORWARDED_FOR') || req.ip
      # Search engines like Google, Bing, Apple webcrawler
      whitelisted_domains = ["search.msn.com","googlebot.com", "applebot.apple.com"]
      whitelisted_domains.any? { |domain| Reversed.lookup(origin_ip).try(:match?, domain) }
    end
  end
end

Rails.application.config.to_prepare do
  # Make #remote_ip method available to rack attack requests:
  # https://github.com/rack/rack-attack/issues/145
  Rack::Attack::Request.class_eval do
    def remote_ip
      @remote_ip ||= ActionDispatch::Request.new(env).remote_ip
    end
  end
end