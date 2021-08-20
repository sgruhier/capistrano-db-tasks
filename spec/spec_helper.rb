require 'bundler/setup'
Bundler.setup

#
# “Note: May need to be looked at if additional tests added”
#
ENV['RAILS_ENV'] = 'development'

class Object 
  def fetch(x)
    false
  end
  def set(x, y)
    true
  end
  def namespace(x)
    true
  end
end
#
# end ”Note: May need to be looked at if additional tests added”
#

require 'capistrano-db-tasks'

RSpec.configure do |config|
end
