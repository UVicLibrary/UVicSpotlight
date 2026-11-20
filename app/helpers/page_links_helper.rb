module PageLinksHelper

  # This helper provides next and previous page links at the bottom of feature pages and the home page

  # @return[Spotlight::Page or NilClass] - nil if we are on the first page or an about page
  def previous_page(page)
    return if page == viewable_pages(page.exhibit).first or omit_page_links?(page)
    viewable_pages(page.exhibit)[viewable_pages(page.exhibit).index(page) - 1]
  end

  # @param[Spotlight::Page] - the current page
  # @param[Integer] - the character length of the displayed link text
  def link_to_previous_page(page, length: 50)
    sanitize("<span class = \"go-to-prev\">" +
      "#{link_to "< " + previous_page(page).title.truncate(length, separator:" "), exhibit_feature_page_path(page.exhibit, previous_page(page))}" +
    "</span>")
  end

  # @return[Spotlight::Page or NilClass] - nil if we are on the last page or an about page
  def next_page(page)
    return if page == viewable_pages(page.exhibit).last or omit_page_links?(page)
    viewable_pages(page.exhibit)[viewable_pages(page.exhibit).index(page) + 1]
  end

  # @param[Spotlight::Page] - the current page
  # @param[Integer] - the character length of the displayed link text
  def link_to_next_page(page, length: 50)
    sanitize("<span class = \"go-to-next\">" +
      "#{link_to next_page(page).title.truncate(length, separator: ' ') + " >", exhibit_feature_page_path(page.exhibit, next_page(page))}" +
    "</span>")
  end

  private

  def viewable_pages(exhibit)
    home_pages = can?(:read, exhibit.home_page) ? [exhibit.home_page] : []
    home_pages + featured(exhibit).select { |page| can?(:read, page) }.uniq
  end

  def featured(exhibit)
    @featured ||= exhibit.feature_pages
  end

  def omit_page_links?(page)
    included_classes = [Spotlight::HomePage, Spotlight::FeaturePage]
    included_classes.exclude? page.class
  end

end