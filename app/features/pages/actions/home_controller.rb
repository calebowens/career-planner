class Pages::Actions::HomeController < ApplicationController
  class View < ApplicationView
    def template
      render Components::Header.new

      main do
        section do
          h1 { "Welcome to career composer!" }

          h2 { "What is career composer?" }
          p { "Career composer is a tool to help you create a career plan by breaking down your long term goals into smaller, more manageable peacies" }

          p { "Career composer will walk you through breaking your dream job into small, manageable steps and suggest action points to help you achieve those steps" }
        end
      end
    end
  end

  def handle
    render View
  end
end
