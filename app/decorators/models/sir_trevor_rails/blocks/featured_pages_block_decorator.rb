# OVERRIDE blacklight-spotlight v.5.0.1
module SirTrevorRails
  module Blocks
    module FeaturedPagesBlockDecorator
      
      # OVERRIDE: Limit visible pages to pages that the current user/ability can view,
      # instead of only public pages (what default Spotlight does).
      def pages(current_ability)
        @pages ||= parent.exhibit.pages.where(slug: item_ids).for_default_locale.select do |page|
          current_ability.can?(:read, page)
        end.sort do |a, b|
          ordered_items.index(a.slug) <=> ordered_items.index(b.slug)
        end
      end

      def pages?(current_ability)
        !pages(current_ability).empty?
      end
      
    end
  end
end
SirTrevorRails::Blocks::FeaturedPagesBlock.prepend(SirTrevorRails::Blocks::FeaturedPagesBlockDecorator)