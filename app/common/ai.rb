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
          content: "Could you please suggest three action points. I'm currently working towards my goal of #{user.dream.current_step.goal}."
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
