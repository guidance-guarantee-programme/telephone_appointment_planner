module DialogHelpers
  def stub_prompt_to_return(title)
    page.evaluate_script <<-JS
      window.prompt = function() {
        return "#{title}";
      };
    JS
  end
end
