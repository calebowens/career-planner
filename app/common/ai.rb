module Ai
  MODEL = "gpt-3.5-turbo-0125"
  OPEN_AI_URI = URI("https://api.openai.com/v1/chat/completions")

  def self.action_point_suggestions(user)
    token = Rails.configuration.open_ai_token

    data = {
      model: MODEL,
      messages: [
        {
          role: "system",
          content: "You are an expert mentor. You provide advice only in single line bullet points"
        },
        {
          role: "user",
          content: "Could you please suggest four small short term action points to help me work towards my goal of #{user.dream.current_step.goal}. My eventual goal is to be a #{user.dream.role}"
        }
      ]
    }.to_json

    headers = {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }

    res = Net::HTTP.post(OPEN_AI_URI, data, headers)
    JSON.parse(res.body)["choices"][0]["message"]["content"].split("\n").map { _1.sub("- ", "") }
  end

  def self.step_suggestions(user)
    token = Rails.configuration.open_ai_token

    prompt =
      if user.dream.steps.empty?
        "My current role is #{user.profile.current_job_title} with #{user.profile.years_of_professional_experience} years of experience. I'm currently #{user.profile.employment_type} in the #{user.profile.current_industry} at a company with #{user.profile.current_company_size} people. My dream is to become a #{user.dream.role}. I would like some suggestions for roles and responsiblities that would be a good halfway point."
      else
        "My current role is #{user.profile.current_job_title} with #{user.profile.years_of_professional_experience} years of experience. I'm currently #{user.profile.employment_type} in the #{user.profile.current_industry} at a company with #{user.profile.current_company_size} people. My dream is to become a #{user.dream.role}. I would like some suggestions for to help me achieve my current goal of #{user.dream.current_step.goal}. Make one of the four suggestions about a new job title or responsibility I could take on"
      end

    data = {
      model: MODEL,
      messages: [
        {
          role: "system",
          content: "You are an expert mentor. You provide advice only in single line bullet points"
        },
        {
          role: "user",
          content: prompt
        }
      ]
    }.to_json

    headers = {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }

    res = Net::HTTP.post(OPEN_AI_URI, data, headers)
    JSON.parse(res.body)["choices"][0]["message"]["content"].split("\n").map { _1.sub("- ", "") }
  end
end
