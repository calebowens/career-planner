class Dream::Pages::SetupController < ApplicationController
  class ViewContext < ActiveSupport::CurrentAttributes
    attribute :form_object
  end

  class FormObject
    include ActiveModel::Model
    include HasErrors

    attr_accessor :role, :timespan

    validates :role, :timespan, presence: true
  end

  class View < ApplicationView
    def template
      render Components::Header
      main do
        section do
          h1 { "What is your dream?" }
          p { "What position do you see yourself in in 10 to 15 years time?" }

          render Form
        end
      end
    end
  end

  class Form < ApplicationView
    def template
      form_with model: ViewContext.form_object, url: "#", method: :put, id: "dream" do |f|
        f.label :role, "What is your dream role?"
        f.text_field :role, placeholder: "Chief Technical Officer"
        render ViewContext.form_object.errors_for(:role)

        f.label :timespan, "In how many years time would you like to achieve this role?"
        f.number_field :timespan, placeholder: "13"
        render ViewContext.form_object.errors_for(:timespan)

        f.submit "Save"
      end
    end
  end

  before_action :authenticate!

  def view
    ViewContext.form_object = FormObject.new(Current.user.dream.attributes)

    render View
  end

  def submit
    ViewContext.form_object = FormObject.new(profile_params)

    if ViewContext.form_object.valid?
      first_time = !Current.user.dream.added?

      Current.user.dream.role = profile_params[:role]
      Current.user.dream.timespan = profile_params[:timespan]
      Current.user.dream.save!

      if first_time
        flash[:notice] = "Successfuly set up dream!"
        redirect_to dashboard_home_path
      else
        flash[:notice] = "Successfuly updated dream!"
        redirect_to dream_setup_path
      end
    else
      render_or_replace_id(
        page: -> { View.new },
        target_id: "dream",
        replacement: -> { Form.new }
      )
    end
  end

  private

  def profile_params
    params.require(:dream_pages_setup_controller_form_object).permit(
      :role,
      :timespan
    )
  end
end
