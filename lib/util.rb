module Util
  def self.prompt(msg, prompt = "(y)es, (n)o ")
    answer = Capistrano::CLI.ui.ask("#{msg} #{prompt} ? ") do |q|
      q.overwrite = false
      q.validate = /^y$|^yes$|^n$|^no$/i
      q.responses[:not_valid] = prompt
    end
    (answer =~ /^y$|^yes$/i) == 0
  end
end
