module Util
  def self.prompt(msg, prompt = "(y)es, (n)o ")
    answer = Capistrano::CLI.ui.ask("#{msg} #{prompt} ? ") do |q|
      q.overwrite = false
      q.validate = /^y$|^yes$|^n$|^no$/i
      q.responses[:not_valid] = prompt
    end
    (answer =~ /^y$|^yes$/i) == 0
  end

  def self.sign_with_stage(stage)
    answer = Capistrano::CLI.ui.ask("WARNING: This is a destructive action. Please type the stage that you're deploying to in order to continue: ") do |q|
      q.overwrite = false
    end
    answer == stage
  end
end
