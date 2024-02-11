class User
  class Dream
    class DreamUpdateError < StandardError
    end

    class Step
      def initialize(step:)
        @step = step
      end

      def target_date
        @step["target_date"]
          .presence
          &.then { DateTime.rfc2822(_1) }
      end

      def target_date=(value)
        if value.is_a? String
          value = DateTime.parse(value)
        end

        @step["target_date"] = value.rfc2822
      end

      def goal
        @step["goal"]
      end

      def goal=(value)
        @step["goal"] = value
      end

      def completed
        @step.fetch("completed", false)
      end

      def completed?
        completed
      end

      def completed=(value)
        @step["completed"] = value
      end

      def id
        @step["id"]
      end

      def id=(value)
        @step["id"] = value
      end

      def json
        @step
      end
    end

    class ActionPoint
      def initialize(action_point:)
        @action_point = action_point
      end

      def id
        @action_point["id"]
      end

      def id=(value)
        @action_point["id"] = value
      end

      def action
        @action_point["action"]
      end

      def action=(value)
        @action_point["action"] = value
      end

      def completed
        @action_point.fetch("completed", false)
      end

      def completed?
        completed
      end

      def completed=(value)
        @action_point["completed"] = value
      end

      def json
        @action_point
      end
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

    # Steps to be completed last to first
    def steps
      @dream["steps"] ||= []

      @dream["steps"].map { Step.new(step: _1) }
    end

    def completed_steps
      steps.select(&:completed?)
    end

    def incomplete_steps
      steps.reject(&:completed?)
    end

    def current_step
      incomplete_steps.last
    end

    def next_step_date
      if steps.empty?
        (timespan.years / 2).from_now
      else
        ((current_step.target_date.to_i - DateTime.now.to_i) / 2).seconds.from_now
      end
    end

    def add_step(goal:)
      step = Step.new(step: {})
      step.target_date = next_step_date
      step.goal = goal
      step.id = SecureRandom.uuid
      @dream["steps"] ||= []
      @dream["steps"] << step.json
    end

    def should_create_new_step?
      next_step_date > 2.months.from_now
    end

    def action_points
      @dream["action_points"] ||= []

      @dream["action_points"].map { ActionPoint.new(action_point: _1) }
    end

    def completed_action_points
      action_points.select(&:completed?)
    end

    def incomplete_action_points
      action_points.reject(&:completed?)
    end

    def add_action_point(action:)
      action_point = ActionPoint.new(action_point: {})
      action_point.id = SecureRandom.uuid
      action_point.action = action
      @dream["action_points"] ||= []
      @dream["action_points"] << action_point.json
    end

    def delete_action_point(id)
      @dream["action_points"] = action_points.reject { _1.id == id }.map(&:json)
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
