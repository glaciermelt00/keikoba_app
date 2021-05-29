module RequestLoginHelper
  def log_in_as(user)
    post '/login', params: { session: {
      email: user.email,
      password: user.password
    } }
    session[:user_id] = user.id
  end

  RSpec.configure do |config|
    config.include RequestLoginHelper
  end
end
