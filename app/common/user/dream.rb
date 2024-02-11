class User
  class Dream
    class DreamUpdateError < StandardError
    end

    def initialize(db_user:, dream:)
      @db_user = db_user
      @dream = dream
    end

    def save!
      unless @db_user.save
        raise DreamUpdateError, "Failed to update dream #{@db_user.errors.full_messages.join(", ")}"
      end
    end

    def role = @dream["role"]

    def role=(other)
      return if other.blank?

      @dream["role"] = other
    end

    def timespan = @dream["timespan"]

    def timespan=(other)
      return if other.blank?

      @dream["timespan"] = other.to_i
    end

    def steps
      @dream["steps"] ||= []
    end

    def attributes
      {
        role:,
        timespan:
      }
    end

    def added?
      attributes.values.all?(&:present?)
    end
  end
end
