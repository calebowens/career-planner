class Dashboard::Pages::ActionPointSuggestionsController < ApplicationController
  before_action :authenticate!

  class View < ApplicationView
    def initialize(prompt:)
      @prompt = prompt
    end

    def template
      turbo_frame_tag :action_point_suggestions do
        p(class: "mt-0") { @prompt }

        ul(class: "mb-0") do
          Ai.action_point_suggestions(Current.user).each do |suggestion|
            li { p { suggestion } }
          end
        end

        link_to "Not happy with these suggestions? Load some more!", dashboard_action_point_suggestions_path(prompt: @prompt)
      end
    end
  end

  def view
    prompt = params[:prompt].presence || "You've not got any action points set up at the minute, if you need some inspiriation, here are some suggestions:"
    render View.new(prompt:), layout: nil
  end
end
