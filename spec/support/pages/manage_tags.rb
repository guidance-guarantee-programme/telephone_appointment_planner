module Pages
  class ManageTags < SitePrism::Page
    set_url '/tags'

    elements :tags, '.t-tag'
  end
end
