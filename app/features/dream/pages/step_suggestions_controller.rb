class Dream::Pages::StepSuggestionsController < ApplicationController
  before_action :authenticate!

  class View < ApplicationView
    def template
      turbo_frame_tag :dream_step_suggestions do
        p(class: "mt-0") { "Are you stuck for ideas? Here are some suggestions:" }

        ul(class: "mb-0") do
          Ai.step_suggestions(Current.user).each do |suggestion|
            li { p { suggestion } }
          end
        end

        link_to "Not happy with these suggestions? Load some more!", dream_step_suggestions_path
      end
    end
  end

  def view
    render View, layout: nil
  end
end
