class Dream::Pages::AddStepController < ApplicationController
  class ViewContext < ActiveSupport::CurrentAttributes
    attribute :form_object
  end

  class FormObject
    include ActiveModel::Model
    include HasErrors

    attr_accessor :goal

    validates :goal, presence: true
  end

  class View < ApplicationView
    def template
      render Components::Header
      main do
        section do
          formatted_date = Current.user.dream.next_step_date.strftime("%F")
          if Current.user.dream.steps.empty?
            h1 { "Lets add your first step" }

            p { "This will create a step with a target completion date of #{formatted_date}." }
            p { "We will guide you through adding steps half way between the current date and the target completion date of the next step" }
          else
            h1 { "Add a step" }

            p { "This will create a step with a target completion date of #{formatted_date}." }
            p { "This step will come before: #{Current.user.dream.steps.last.goal}" }
          end

          p(class: "mt-2") { "This should be a long-term and objective goal like taking on a new role or responsiblity" }

          render Form

          div(class: "card") do
            turbo_frame_tag :dream_step_suggestions, src: dream_step_suggestions_path do
              p(class: "mt-0") { "Are you stuck for ideas? Here are some suggestions:" }

              p(class: "mb-0") { "Loading..." }
            end
          end
        end
      end
    end
  end

  class Form < ApplicationView
    def template
      form_with model: ViewContext.form_object, url: dream_add_step_path, method: :post, id: "step" do |f|
        f.label :goal, "Enter your goal"
        f.text_field :goal, placeholder: "Become a lead developer"
        render ViewContext.form_object.errors_for(:goal)

        f.submit "Save"
      end
    end
  end

  before_action :authenticate!

  def view
    ViewContext.form_object = FormObject.new

    render View
  end

  def submit
    ViewContext.form_object = FormObject.new(step_params)

    if ViewContext.form_object.valid?
      Current.user.dream.add_step(goal: step_params[:goal])
      Current.user.dream.save!

      flash[:notice] = "Successfuly added step!"

      if Current.user.dream.should_create_new_step?
        redirect_to dream_add_step_path
      else
        redirect_to dashboard_home_path
      end
    else
      render_or_replace_id(
        page: -> { View.new },
        target_id: "step",
        replacement: -> { Form.new }
      )
    end
  end

  def step_params
    params.require(:dream_pages_add_step_controller_form_object).permit(
      :goal
    )
  end
end
