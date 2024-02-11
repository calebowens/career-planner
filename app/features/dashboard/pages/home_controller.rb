class Dashboard::Pages::HomeController < ApplicationController
  class View < ApplicationView
    def template
      render Components::Header.new

      main do
        section do
          h1 { "Welcome #{Current.user.profile.name}!" }

          h2 { "Your dream is to become a #{Current.user.dream.role}" }

          p { "This month the step your working on is: \"Develop communication skills\"" }

          button(class: "secondary") { "I've completed this step" }

          h3 { "Action points" }

          ul do
            with_options class: "p" do |styled|
              styled.li { "When discussing ideas, ask open questions" }
              styled.li {
                plain "✅"
                s { "Complete 5 code reviews with constructive feedback provided" }
              }
            end
          end

          h2 { "Upcoming steps:" }
          ul do
            with_options class: "p" do |styled|
              styled.li { "Develop communication skills" }
              styled.li { "Take on two small non-development roles with the company" }
              styled.li { "Develop soft skills in line with guidance from company progression doc" }
              styled.li { "Build up foundational skills for leadership" }
              styled.li { "Take on a senior developer position" }
              styled.li { "Take on a lead developer position" }
              styled.li { "Become a Chief Techincal Officer" }
            end
          end

          h2 { "Completed steps:" }
          ul do
            with_options class: "p" do |styled|
              styled.li {
                plain "✅"
                s { "Take on a mid level developer position" }
              }
            end
          end
        end
      end
    end
  end

  before_action :authenticate!
  before_action :ensure_profile_completed!
  before_action :ensure_dream_added!

  def view
    render View
  end
end
