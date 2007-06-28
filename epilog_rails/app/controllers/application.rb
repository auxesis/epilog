# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_log_test_session_id'

  # usefully ripped from http://www.railsenvy.com/2007/2/19/acts-as-ferret-tutorial
  def pages_for(size, options = {})
    default_options = {:per_page => 10}
    options = default_options.merge options
    pages = Paginator.new self, size, options[:per_page], (params[:page]||1)
    return pages
  end
end
