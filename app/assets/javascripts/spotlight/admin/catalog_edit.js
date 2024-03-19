function removeDuplicate() {
	blocks = document.getElementsByClassName('st-block');
	Array.from(blocks).forEach(function(block) { 
		if(block.attributes["data-instance"].value == 'st-editor-1')
			block.remove();
	});
	top_el = document.getElementsByClassName('st-top-controls');
	if(top_el.length>1)
		top_el[top_el.length-1].remove();
}

Spotlight.onLoad(function() {
	setInterval(removeDuplicate, 1000);

// see vendor/assets/javascripts/sir-trevor.js#3906 for where the icon
// is added to the SirTrevor pop-up FormatBar when text is highlighted
  $(document).on('click', '.st-format-btn--Footnote', function(){

    var selection = window.getSelection().getRangeAt(0);

    var footnoteNum = window.prompt('Enter footnote number');

    // Generate link with the footnote number
    var aElement = document.createElement('a');
    var anchor = '#footnote-' + footnoteNum;
    aElement.setAttribute('href', anchor);
    aElement.textContent = footnoteNum;

    var oldText = selection.endContainer; // The text node inside <p>
    var parentNode = selection.endContainer.parentNode; // <p>
    // Split the text at the end of the selection (highlighted text)
    var textAfter = oldText.splitText(selection.endOffset);
    // Insert the link after the selected text
    parentNode.insertBefore(aElement,textAfter);

  });
	
  if($('#solr_document_exhibit_tag_list').length > 0) {
    // By default tags input binds on page ready to [data-role=tagsinput],
    // however, that doesn't work with Turbolinks. So we init manually:
    $('#solr_document_exhibit_tag_list').tagsinput();

    var tags = new Bloodhound({
      datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.name); },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      limit: 100,
      prefetch: {
        url: $('#solr_document_exhibit_tag_list').data('autocomplete_url'),
        ttl: 1,
        filter: function(list) {
          return $.map(list, function(tag) { return { name: tag }; });
        }
      }
    });

    tags.initialize();

    $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead({highlight: true, hint: false}, {
      name: 'tags',
      displayKey: 'name',
      source: tags.ttAdapter()
    }).bind('typeahead:selected', $.proxy(function (obj, datum) {
      $('#solr_document_exhibit_tag_list').tagsinput('add', datum.name);
      $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead('val', '');
    })).bind('blur', function() {
      $('#solr_document_exhibit_tag_list').tagsinput('add', $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead('val'));
      $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead('val', '');
    });
  }

      $(".visiblity_toggle").bl_checkbox_submit({
          //css_class is added to elements added, plus used for id base
          css_class: "toggle_visibility",
          //success is called at the end of the ajax success callback
          success: function (isPublic){
            // We store the selector of the label to toggle in a data attribute in the form
            var docTarget = $($(this).data("label-toggle-target"));
            if ( isPublic ) {
              docTarget.removeClass("blacklight-private");
            } else {
              docTarget.addClass("blacklight-private");
            }
          }
      });

});
