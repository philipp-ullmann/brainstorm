# Main controller tasks.
class ApplicationController < ActionController::API
  include Pundit, Authentication, ExceptionHandler
end
