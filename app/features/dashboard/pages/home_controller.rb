class Dashboard::Pages::HomeController < ApplicationController
  class ViewContext < ActiveSupport::CurrentAttributes
    attribute :action_point_form_object
  end

  class View < ApplicationView
    def template
      render Components::Header.new

      main do
        section do
          h1 { "Welcome #{Current.user.profile.name}!" }

          h2 { "Your dream is to become a #{Current.user.dream.role}" }

          p { "Your current step is: #{Current.user.dream.current_step.goal}" }
          p { "The target completion date for this goal is: #{Current.user.dream.current_step.target_date.strftime("%F")}" }

          button_to "I've completed this step", dashboard_complete_step_path, method: :post, class: :secondary

          render ActionPoints

          render UpcomingSteps
          render CompletedSteps
        end
      end
    end
  end

  class ActionPointFormObject
    include ActiveModel::Model
    include HasErrors

    attr_accessor :action

    validates :action, presence: true
  end

  class ActionPoints < ApplicationView
    def template
      h3 { "Action points" }

      p { "Action points are short term goals that help guide you towards completing your current step" }

      ul do
        Current.user.dream.incomplete_action_points.each do |action_point|
          li do
            p { action_point.action }
            div(class: "flex") do
              button_to "Mark complete", dashboard_toggle_action_point_path(action_point.id)
              button_to "Delete", dashboard_delete_action_point_path(action_point.id), method: :delete, class: "danger"
            end
          end
        end

        Current.user.dream.completed_action_points.each do |action_point|
          li do
            p do
              plain "✅"
              s { action_point.action }
            end

            button_to "Mark incomplete", dashboard_toggle_action_point_path(action_point.id)
          end
        end
      end

      form_with(model: ViewContext.action_point_form_object, url: dashboard_add_action_point_path, method: :post, class: "flex", id: "action_point_form") do |f|
        f.text_field :action
        render ViewContext.action_point_form_object.errors_for(:action)

        f.submit "Create action point"
      end
    end
  end

  class UpcomingSteps < ApplicationView
    def template
      h2 { "Upcoming steps:" }
      ul do
        Current.user.dream.incomplete_steps.reverse[1..].each do |step|
          li do
            p { "#{step.goal} (#{step.target_date.strftime("%F")})" }
          end
        end
      end
    end
  end

  class CompletedSteps < ApplicationView
    def template
      h2 { "Completed steps:" }
      if Current.user.dream.completed_steps.empty?
        p { "You've not completed any steps; don't be discoraged, you'll get going in no time!" }
      else
        ul do
          Current.user.dream.completed_steps.reverse_each do |step|
            li do
              p do
                plain "✅"
                s { "#{step.goal} (#{step.target_date.strftime("%F")})" }
              end
            end
          end
        end
      end
    end
  end

  before_action :authenticate!
  before_action :ensure_profile_completed!
  before_action :ensure_dream_added!
  before_action :ensure_dream_steps_added!
  before_action :set_action_point_form_object

  def view
    render View
  end

  def complete_step
    Current.user.dream.current_step.completed = true
    Current.user.dream.save!

    redirect_to dashboard_home_path
  end

  def add_action_point
    ViewContext.action_point_form_object = ActionPointFormObject.new(action_point_params)

    if ViewContext.action_point_form_object.valid?
      Current.user.dream.add_action_point(action: action_point_params[:action])
      Current.user.dream.save!

      flash[:notice] = "Successfuly added action point!"

      redirect_to dashboard_home_path
    else
      render_or_replace_id(
        page: -> { View.new },
        target_id: "action_point_form",
        replacement: -> { Form.new }
      )
    end
  end

  def toggle_action_point
    action_point = Current.user.dream.action_points.find { _1.id == params[:id] }

    action_point.completed = !action_point.completed
    Current.user.dream.save!

    transitioned_to = action_point.completed ? "completed" : "incomplete"

    flash[:notice] = "Successfuly marked added action point as #{transitioned_to}!"

    redirect_to dashboard_home_path
  end

  def delete_action_point
    Current.user.dream.delete_action_point(params[:id])
    Current.user.dream.save!

    flash[:notice] = "Successfuly deleted action point!"

    redirect_to dashboard_home_path
  end

  private

  def set_action_point_form_object
    ViewContext.action_point_form_object = ActionPointFormObject.new
  end

  def action_point_params
    params.require(:dashboard_pages_home_controller_action_point_form_object).permit(
      :action
    )
  end
end
