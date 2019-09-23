class PensionProvider
  def self.all
    @all ||= begin
               JSON.parse(ENV.fetch('PENSION_PROVIDERS', '{}')).merge(
                 'n/a' => 'Not Applicable'
               )
             end
  end

  def self.[](key)
    all[key]
  end
end
