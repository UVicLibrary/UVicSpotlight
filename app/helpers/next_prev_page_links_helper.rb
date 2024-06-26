module NextPrevPageLinksHelper

  def viewable_pages
    viewable_features = (@exhibit.feature_pages.select { |page| can? :edit, page } + @exhibit.feature_pages.published).uniq
    [@exhibit.home_page, viewable_features].flatten
  end

  def viewable_child_pages(page)
    (page.child_pages.select { |page| can? :edit, page } + page.child_pages.published).uniq
  end

  def top_level(pages_array)
    pages_array.select { |page| !page.home_page? && page.parent_page.nil? }
  end

  def previous_page
    return if @page == viewable_pages.first or omit_page_links?
    viewable_pages[viewable_pages.index(@page) - 1]
  end

  def next_page
    return if @page == viewable_pages.last or omit_page_links?
    viewable_pages[viewable_pages.index(@page) + 1]
  end

  def omit_page_links?
    included_classes = [Spotlight::HomePage, Spotlight::FeaturePage]
    included_classes.exclude? @page.class
  end

end