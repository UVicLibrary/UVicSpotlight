// Functions used by the catalog#show page

jQuery(document).ready(function() {
    if (!!window.parent.location.href.match(/catalog\/\d+-\d+/)) {
        // Catch messages posted by the Mirador iframe in app/views/catalog/viewers/mirador_fullscreen
        window.addEventListener('message', event => updatePageMetadata(event.data));
    }
});

// Collapse/expand metadata fields when user clicks the field label
function hideShow(event) {
    let icon = $(event.target).find('i.fa');
    let value = $(event.target.closest('div.metadata-field')).find('dd');

    if (value.css("display") == "none") {
        value.css("display", "block");
        icon.removeClass("fa-chevron-right");
        icon.addClass("fa-chevron-down");
    } else {
        value.css("display", "none");
        icon.removeClass("fa-chevron-down");
        icon.addClass("fa-chevron-right");
    }
}

// For compound objects, update the metadata sidebar with file-level metadata
// from the SolrDocument included in .compound_ids attribute.
// @param[<String>] - a parseable JSON object like '{ "canvasIndex": 1 }',
// where canvasIndex is the index of the page to render
function updatePageMetadata(message) {
    if (typeof(message) == 'string') {
        try {
            details = JSON.parse(message);
            canvasId = details.canvasIndex;
            metadataSidebar = $('#metadata-sidebar');

            metadataSidebar.children().hide();
            currentPage = metadataSidebar.find('#page_' + canvasId);
            currentPage.show();
        } catch(e) {
            // If it's not a parseable JSON object, then it's
            // probably an unrelated message and we should do nothing.
            return;
        }
    }
}

// For audio/video compound objects, change the player to play the currently
// selected file.
function updatePlayer(el, totalCount) {
    playerIndex = parseInt(document.getElementById('osd-page').innerHTML);
    if (el.id == "osd-previous")
        playerIndex--;
    else
        playerIndex++;
    if (playerIndex > totalCount)
        playerIndex = 1;
    if (playerIndex < 1)
        playerIndex = totalCount;
    document.getElementById('osd-page').innerHTML = playerIndex;
    var audioplayers = $('.audioplayer');
    $.each(audioplayers, function (index, value) {
        value.style.display = "none";
        value.pause();
    });
    document.getElementById('audio_'+(playerIndex - 1)).style.display = "block";
    updatePageMetadata(`{ "canvasIndex" : ${playerIndex - 1} }`)
}