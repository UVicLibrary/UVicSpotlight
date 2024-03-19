//= require spotlight/admin/blocks/solr_documents_base_block

SirTrevor.Blocks.SolrDocumentsEmbed = (function(){

    return SirTrevor.Blocks.SolrDocumentsBase.extend({
        type: "solr_documents_embed",

        icon_name: "item_embed",

        item_options: function() {
            // this.initialize_mirador_options();
            return this.mirador_options();
        },

        mirador_options: function() {
        return [
            '<div class="row">',
            '<div class="col-md-12">',
            '<div>',
            '<p>Display images using:</p>',
            '<input data-key="use-mirador" type="radio" name="<%= formId("use-mirador") %>" id="<%= formId("use-mirador-true") %>" value="true" checked="true">',
            '<label for="<%= formId("use-mirador-true") %>" style="margin-right:1rem;">Zoomable Viewer</label>',
            '<input data-key="use-mirador" type="radio" name="<%= formId("use-mirador") %>" id="<%= formId("use-mirador-false") %>" value="false">',
            '<label for="<%= formId("use-mirador-false") %>">Static Image</label>',
            '</div>',
            '</div>',
            '</div>'].join("\n");
        },

        // initialize_mirador_options() {
        //     debugger
        //     if (_.isUndefined(this['use-mirador'])) {
        //         this.use_mirador = 'true';
        //     }
        // },

        afterPreviewLoad: function(options) {
            // $(this.inner).find('picture[data-openseadragon]').openseadragon();
        }
});

})();
