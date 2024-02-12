class Dashboard::Pages::ActionPointSuggestionsController < ApplicationController
  before_action :authenticate!

  class View < ApplicationView
    def template
      turbo_frame_tag :action_point_suggestions do
        p(class: "mt-0") { "You've not got any action points set up at the minute, if you need some inspiriation, here are some suggestions:" }

        ul(class: "mb-0") do
          Ai.action_point_suggestions(Current.user).each do |suggestion|
            li { p { suggestion } }
          end
        end
      end
    end
  end

  def view
    render View, layout: nil
  end
end
