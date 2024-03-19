(function ($){
    SirTrevor.BlockMixins.Togglemirador = {
        mixinName: "toggleMirador",
        preload: true,

        initializeMirador: function() {
            if (_.isUndefined(this['use_mirador'])) {
                this.use_mirador = true;
            }

            // if (_.isUndefined(this['formId'])) {
            //     this.withMixin(SirTrevor.BlockMixins.Formable);
            // }
            //
            // if (_.isUndefined(this['show_heading'])) {
            //     this.show_heading = true;
            // }
        },

        align_key:"text-align",
        text_key:"item-text",
        heading_key: "title",

        text_area: function() {
            return _.template([
                '<div class="row">',
                '<div class="col-md-4">',
                '<div class="text-align">',
                '<p>Use deep zoom (Mirador) viewer or static image:</p>',
                '<input data-key="<%= align_key %>" type="radio" name="<%= formId(align_key) %>" id="<%= formId(align_key + "-left") %>" value="left" checked="true">',
                '<label for="<%= formId(align_key + "-left") %>"><%= i18n.t("blocks:textable:align:left") %></label>',
                '<input data-key="<%= align_key %>" type="radio" name="<%= formId(align_key) %>" id="<%= formId(align_key + "-right") %>" value="right">',
                '<label for="<%= formId(align_key + "-right") %>"><%= i18n.t("blocks:textable:align:right") %></label>',
                '</div>',
                '</div>',
                '</div>'].join("\n"))(this); },

        heading: function() {
            if(this.show_heading) {
                return ['<div class="field">',
                    '<label for="<%= formId(heading_key) %>" class="control-label"><%= i18n.t("blocks:textable:heading") %></label>',
                    '<input type="text" class="form-control" id="<%= formId(heading_key) %>" name="<%= heading_key %>" />',
                    '</div>'].join("\n");
            } else {
                return "";
            }
        },
    };


    SirTrevor.Block.prototype.availableMixins.push("togglemirador");
})(jQuery);
