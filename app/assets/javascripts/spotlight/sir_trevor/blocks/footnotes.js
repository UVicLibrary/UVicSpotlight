SirTrevor.Blocks.Footnotes = (function(){

    return SirTrevor.Block.extend({

        type: "footnotes",
        formable: true,
        textable: true,
        pastable: true,

        description: 'This widget allows you to embed footnotes. See <a href="https://exhibits.library.uvic.ca/spotlight/tutorials/feature/the-footnotes-block">instructions</a> for more details. There can only be one footnotes block per page.',
        icon_name: "fmt-footnote",

        onBlockRender: function onBlockRender() {
            // Activate tooltips for add and delete footnote buttons
            $(function () {
                $('[data-toggle="tooltip"]').tooltip();
            })

            $('body').on('click', '.add-footnote', function() {
            // $('.add-footnote').click( function() {
                // Get the number in the id/name of the li that was clicked
                prev_footnote = parseInt($(this).siblings('form').find('textarea').attr('name').replace('footnote-',''));
                console.log($(this).siblings('form').find('textarea'));
                // Insert a new footnote textbox after it with the correct id/name
                new_footnote = $(footnoteTextbox(prev_footnote + 1));
                new_footnote.insertAfter($(this));
                // Update the IDs order of the textboxes after the new one (so that they all display in the same order)
                // find current index of the new element
                index = $('.textbox-area li:visible').index(new_footnote.closest('li'));
                // slice the footnotes at the index after that footnote
                start = index + 1;
                end = $('.textbox-area li:visible').length;
                // bump up all the id and name attributes by one
                // for all footnotes after it (from there to the end)
                // update the ids order
                updateFootnoteIds();
                // update_footnote_ids($('.textbox-area li').slice(start, end));
            });

            $('body').on('click', '.remove-footnote', function() {
                // $('.remove-footnote').click( function() {
                console.log("clicked");
                textarea = $(this).siblings('form').find('textarea');
                textarea.val('');
                console.log($(this).closest('li'));
                $(this).closest('li').hide(); // Hide instead of remove because we still need to "erase"
                // the data of the deleted element by setting the value to "" before saving.
                // $(this).closest('li').remove();
                // update_footnote_ids();
            });

            function updateFootnoteIds() {
                for (let i = 0; i < $('.textbox-area li:visible').length; i++) {
                    // Find each li and get its index
                    var footnote = $('.textbox-area li:visible')[i];
                    var footnote_index = i;
                    var new_id = 'footnote-textbox-' + String(footnote_index + 1);
                    var new_name = 'footnote-' + String(footnote_index + 1); // account for zero-indexing
                    // Update the id and name of the textbox to match the index
                    $(footnote).find($('.st-text-block')).attr('id', new_id).attr('name', new_name);
                    //setData
                }
            }

        },

        editorHTML: function() {
            return [
                '<div class="clearfix">',
                '<div class="widget-header">',
                this.description,
                '</div>',
                '<div class="row">',
                    '<div class="col-md-12">',
                        '<ol class="textbox-area" >',
                            this.getFootnotes(this.getBlockData()),
                        '</ol>',
                    '</div>',
                '</div>'
            ].join("\n")
        },

        getFootnotes: function(obj) {
            var array = [];
            if (Object.keys(obj).length > 0) {
                for (x in obj) {
                    if ( obj[x] ) {
                        array.push(footnoteTextbox(Object.keys(obj).indexOf(x) + 1, obj[x]));
                    }
                }
                return array.join("\n");
            } else {
                return footnoteTextbox(1, '');
            }
        }

    });

})();

function footnoteTextbox(counter) { return [
    '<li class="footnote" style="display:' +  ' ">',
        '<div class="footnote-container">',
            '<form class="footnote-form">', //onselect="selected()"
                '<textarea  class="st-text-block form-control" id="footnote-textbox-'
                // '<textarea contenteditable="true" class="st-text-block" contenteditable="true" id="footnote-textbox-'
                + counter.toString() +  '" name="footnote-' + counter.toString() +
                '" placeholder="Footnote text here...">',
                '</textarea><br>',
            '</form>',
        deleteButton(),
        addButton(),
        '</div>',
    '</li>',
].join("\n")
}

function addButton() {
    return [
        '<a class="btn btn-link add-footnote" data-toggle="tooltip" data-placement="right" title="Add footnote after">',
            '<span class="glyphicon glyphicon-plus" aria-hidden="true"></span>',
        '</a>'
    ].join("\n")
}

function deleteButton() {
    return [
        '<a class="btn btn-link remove-footnote" data-toggle="tooltip" data-placement="right" title="Delete this footnote">',
            '<span class="glyphicon glyphicon-remove" aria-hidden="true"></span>',
        '</a>'
    ].join("\n")
}
