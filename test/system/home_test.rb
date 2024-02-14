require "application_cuprite_test"

class HomeTest < ApplicationCupriteTest
  test "home page" do
    visit root_path

    assert_selector "h1", text: "Welcome to career composer!"
  end
end
