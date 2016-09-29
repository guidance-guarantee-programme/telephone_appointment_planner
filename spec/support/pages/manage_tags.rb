module Pages
  class ManageTags < SitePrism::Page
    set_url '/tags'

    sections :tags, '.t-tag' do
      element :delete, '.t-delete'
    end
  end
end
