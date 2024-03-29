# Roda is a simple Rack-based framework with a flexible architecture based
# on the concept of a routing tree. Bridgetown uses it for its development
# server, but you can also run it in production for fast, dynamic applications.
#
# Learn more at: http://roda.jeremyevans.net

class RodaApp < Bridgetown::Rack::Roda
  # Add additional Roda configuration here if needed

  # Uncomment to use Bridgetown SSR:
  # plugin :bridgetown_ssr

  # Uncomment to use file-based dynamic routing in your project (make sure you
  # uncomment the gem dependency in your `Gemfile` as well):
  # plugin :bridgetown_routes

  route do |r|
    # Load Roda routes in server/routes (and src/_routes via `bridgetown-routes`)
    r.bridgetown
  end
end

