module LoginHelper
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

RSpec.configure do |config|
  config.include LoginHelper
end
