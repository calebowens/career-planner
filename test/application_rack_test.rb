require "test_helper"
require "phlex/rails"
require "phlex/testing/rails/view_helper"
require "phlex/testing/capybara"

class ApplicationRackTest < ActionDispatch::SystemTestCase
  def self.include_phlex_helpers
    include Phlex::Testing::Rails::ViewHelper
    include Phlex::Testing::Capybara::ViewHelper
  end

  driven_by :rack_test
end
