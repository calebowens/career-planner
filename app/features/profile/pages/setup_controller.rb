class Profile::Pages::SetupController < ApplicationController
  class ViewContext < ActiveSupport::CurrentAttributes
    attribute :form_object
  end

  class FormObject
    include ActiveModel::Model
    include HasErrors

    attr_accessor :name, :date_of_birth, :current_job_title, :current_industry, :current_company_size, :years_of_professional_experience, :employment_type

    validates :name, :date_of_birth, :current_job_title, :current_industry, :current_company_size, :years_of_professional_experience, :employment_type, presence: true
  end

  class View < ApplicationView
    def template
      render Components::Header
      main do
        section do
          h1 { "Tell us about you" }

          render Form
        end
      end
    end
  end

  class Form < ApplicationView
    def template
      form_with model: ViewContext.form_object, url: profile_setup_path, method: :put, id: "profile" do |f|
        h2 { "Your personal details" }
        f.label :name
        f.text_field :name, placeholder: "John Smith"
        render ViewContext.form_object.errors_for(:name)

        f.label :date_of_birth
        f.date_field :date_of_birth
        render ViewContext.form_object.errors_for(:date_of_birth)

        h2 { "Your professional background" }
        f.label :current_job_title
        f.text_field :current_job_title, placeholder: "Senior Software Developer"
        render ViewContext.form_object.errors_for(:current_job_title)

        f.label :current_industry
        f.text_field :current_industry, placeholder: "FinTech"
        render ViewContext.form_object.errors_for(:current_industry)

        f.label :current_company_size
        f.number_field :current_company_size, placeholder: 25
        render ViewContext.form_object.errors_for(:current_company_size)

        f.label :years_of_professional_experience
        f.number_field :years_of_professional_experience, placeholder: 6
        render ViewContext.form_object.errors_for(:years_of_professional_experience)

        f.label :employment_type
        f.select :employment_type, User::Profile::EMPLOYMENT_TYPES.map { [_1.to_s.titlecase, _1] }.to_h
        render ViewContext.form_object.errors_for(:employment_type)

        f.submit "Save"
      end
    end
  end

  before_action :authenticate!

  def view
    ViewContext.form_object = FormObject.new(Current.user.profile.attributes)

    render View
  end

  def submit
    ViewContext.form_object = FormObject.new(profile_params)

    if ViewContext.form_object.valid?
      first_time = !Current.user.profile.completed?

      Current.user.profile.update!(
        name: profile_params[:name],
        date_of_birth: profile_params[:date_of_birth],
        current_job_title: profile_params[:current_job_title],
        current_industry: profile_params[:current_industry],
        current_company_size: profile_params[:current_company_size],
        years_of_professional_experience: profile_params[:years_of_professional_experience],
        employment_type: profile_params[:employment_type]
      )

      if first_time
        flash[:notice] = "Successfuly set up profile!"
        redirect_to dashboard_home_path
      else
        flash[:notice] = "Successfuly updated profile!"
        redirect_to profile_setup_path
      end
    else
      render_or_replace_id(
        page: -> { View.new },
        target_id: "profile",
        replacement: -> { Form.new }
      )
    end
  end

  private

  def profile_params
    params.require(:profile_pages_setup_controller_form_object).permit(
      :name,
      :date_of_birth,
      :current_job_title,
      :current_industry,
      :current_company_size,
      :years_of_professional_experience,
      :employment_type
    )
  end
end
