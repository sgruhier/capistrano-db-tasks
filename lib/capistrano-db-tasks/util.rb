module Util
  def self.prompt(msg, prompt = "(y)es, (n)o ")
    ask(:answer, "#{msg} #{prompt} ? ")
    (fetch(:answer) =~ /^y$|^yes$/i).to_i.zero?
  end
end
