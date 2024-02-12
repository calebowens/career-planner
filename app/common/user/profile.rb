class User
  class Profile
    EMPLOYMENT_TYPES = %i[full_time part_time self_employed]

    class ProfileUpdateError < StandardError
    end

    def initialize(db_user:)
      @db_user = db_user
    end

    def update!(
      name:,
      date_of_birth:,
      current_job_title:,
      current_industry:,
      current_company_size:,
      years_of_professional_experience:,
      employment_type:
    )
      self.date_of_birth = date_of_birth
      professional_background = {
        name:,
        current_job_title:,
        current_industry:,
        current_company_size:,
        years_of_professional_experience:
      }.stringify_keys

      @db_user.profile.merge!(professional_background)
      self.employment_type = employment_type

      unless @db_user.save
        raise ProfileUpdateError, "Failed to update professional background #{@db_user.errors.full_messages.join(", ")}"
      end
    end

    def date_of_birth
      @db_user
        .profile["date_of_birth"]
        .presence
        &.then { DateTime.rfc2822(_1) }
    end

    def date_of_birth=(value)
      if value.is_a? String
        value = DateTime.parse(value)
      end

      @db_user.profile["date_of_birth"] = value.rfc2822
    end

    def employment_type
      @db_user.profile["employment_type"]&.to_sym
    end

    def employment_type=(value)
      @db_user.profile["employment_type"] = value
    end

    def attributes
      {
        name: @db_user.profile["name"],
        date_of_birth:,
        current_job_title: @db_user.profile["current_job_title"],
        current_industry: @db_user.profile["current_industry"],
        current_company_size: @db_user.profile["current_company_size"],
        years_of_professional_experience: @db_user.profile["years_of_professional_experience"],
        employment_type:
      }
    end

    def completed?
      attributes.values.all?(&:present?)
    end

    %i[name current_job_title current_industry current_company_size years_of_professional_experience].each do |attribute|
      define_method attribute do
        @db_user.profile[attribute.to_s]
      end
    end
  end
end
