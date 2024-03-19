(function($) {
    $.fn.bl_checkbox_submit = function(arg_opts) {

      this.each(function() {
        var options = $.extend({}, $.fn.bl_checkbox_submit.defaults, arg_opts);


        var form = $(this);
        form.children().hide();
        //We're going to use the existing form to actually send our add/removes
        //This works conveneintly because the exact same action href is used
        //for both bookmarks/$doc_id.  But let's take out the irrelevant parts
        //of the form to avoid any future confusion.
        form.find("input[type=submit]").remove();
        form.addClass('form-horizontal');

        //View needs to set data-doc-id so we know a unique value
        //for making DOM id
        var unique_id = form.attr("data-doc-id") || Math.random();
        // if form is currently using method delete to change state,
        // then checkbox is currently checked
        var checked = (form.find("input[name=_method][value=delete]").length != 0);

        var checkbox = $('<input type="checkbox">')
          .addClass( options.css_class )
          .attr("id", options.css_class + "_" + unique_id);
        var label = $('<label>')
          .addClass( options.css_class )
          .attr("for", options.css_class + '_' + unique_id)
          .attr("title", form.attr("title") || "");
        var span = $('<span>');

        label.append(checkbox);
        label.append(" ");
        label.append(span);

        var checkbox_div = $("<div class='checkbox' />")
          .addClass(options.css_class)
          .append(label);

        function update_state_for(state) {
            checkbox.prop("checked", state);
            label.toggleClass("checked", state);
            if (state) {
               //Set the Rails hidden field that fakes an HTTP verb
               //properly for current state action.
               form.find("input[name=_method]").val("delete");
               span.text(form.attr('data-present'));
            } else {
               form.find("input[name=_method]").val("put");
               span.text(form.attr('data-absent'));
            }
          }

        form.append(checkbox_div);
        update_state_for(checked);

        checkbox.click(function() {
            span.text(form.attr('data-inprogress'));
            label.attr("disabled", "disabled");
            checkbox.attr("disabled", "disabled");

            $.ajax({
                url: form.attr("action"),
                dataType: 'json',
                type: form.attr("method").toUpperCase(),
                data: form.serialize(),
                error: function() {
                   alert("Error");
                   update_state_for(checked);
                   label.removeAttr("disabled");
                   checkbox.removeAttr("disabled");
                },
                success: function(data, status, xhr) {
                  //if app isn't running at all, xhr annoyingly
                  //reports success with status 0.
                  if (xhr.status != 0) {
                    checked = ! checked;
                    update_state_for(checked);
                    label.removeAttr("disabled");
                    checkbox.removeAttr("disabled");
                    options.success.call(form, checked, xhr.responseJSON);
                  } else {
                    alert("Error");
                    update_state_for(checked);
                    label.removeAttr("disabled");
                    checkbox.removeAttr("disabled");
                  }
                }
            });

            return false;
        }); //checkbox.click


      }); //this.each
      return this;
    };

  $.fn.bl_checkbox_submit.defaults =  {
            //css_class is added to elements added, plus used for id base
            css_class: "bl_checkbox_submit",
            success: function() {} //callback
  };
})(jQuery);

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
          success: function (public){
            // We store the selector of the label to toggle in a data attribute in the form
            var docTarget = $($(this).data("label-toggle-target"));
            if ( public ) {
              docTarget.removeClass("blacklight-private");
            } else {
              docTarget.addClass("blacklight-private");
            }
          }
      });

});
