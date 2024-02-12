class Pages::Actions::HomeController < ApplicationController
  class View < ApplicationView
    def template
      render Components::Header.new

      main do
        section do
          h1 { "Welcome to career composer!" }
        end
      end
    end
  end

  def handle
    render View
  end
end
