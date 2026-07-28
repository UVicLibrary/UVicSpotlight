// Add the footnote icon from assets/images/spotlight/sir-trevor-icons
// to the formatBar that pops up when text is highlighted
window.SirTrevor.config.defaults.formatBar.commands.push(
    {
        name: "Footnote",
        title: "footnote",
        iconName: "fmt-footnote",
        cmd: "footnote",
        text: "footnote"
    }
)

window.Spotlight.onLoad(function() {

    // Clicking the footnote icon adds an anchor link to the footnotes block
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

});
