//= require spotlight/admin/blocks/solr_documents_base_block

SirTrevor.Blocks.AudioWithImage = (function(){

    //return SirTrevor.Blocks.SolrDocumentsBase.extend({

    return SirTrevor.Blocks.SolrDocumentsEmbed.extend({

        toolbarEnabled: true,
        type: "audio_with_image",

        icon_name: "audio_with_image",
        //
        content: function() {
            var templates = [
                this.items_selector()
            ];
            if (this.plustextable) {
                templates.push('<hr/>' + this.text_area());
            }
            return _.template(templates.join("\n"))(this); //<hr/>
        },

        items_selector: function() { return [
            '<div class="row">',
            '<div class="col-md-8">',
            '<div class="form-group">',
            // container for item panels
            '<div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">',
            '<ol class="dd-list"></ol>',
            '</div>',
            '<label style="margin-top: 20px;">Select Image and Audio</label>',
            this.autocomplete_control(),
            '</div>',
            '</div>',
            '<div class="col-md-4">',
            this.item_options(),
            '</div>',
            '</div>'].join("\n")
        },

        item_options: function() {
            if (this.use_viewer == "true") {
                var checked = 'checked="checked"';
            } else {
                var checked = '';
            }
            return [
                '<input type="hidden" id="hidden-use-viewer" name="use_viewer" value="nil">', // Update use viewer to nil if box is unchecked.
                '<input type="checkbox" name="use_viewer" id="use-viewer" value="true"' + checked
                + ' /><label for="use-viewer" style="margin-left:5px;">Use image viewer</label>',
                '<p>Allow zoom and other features from the default viewer.</p>'
            ].join("\n")
        },
    });

})();
