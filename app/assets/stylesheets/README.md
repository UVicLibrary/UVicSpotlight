## Naming Conventions for Custom CSS Files

### Overriding a Gem

New CSS files should go in a subdirectory named `<gem name>_overrides`, for example: `sir_trevor_overrides` 
when overriding the `sir-trevor-rails` gem. If the file is placed in an existing folder, it should already be included
in `application.scss`. Otherwise, import the whole subdirectory and its files like so:

```css
@import "<gem_name>_overrides/*";
```

Ideally, the file should be named after the view that it modifies. The filepath doesn't need to mirror the exact path 
from `app/views`, since that might create an overcomplicated nesting structure. One strategy is to include the filepath in the 
name of the file itself. For example, a CSS file that modifies `app/views/spotlight/exhibits/index.html.erb` might be 
organized/named like so:

```
app/assets/stylesheets
   |__spotlight_overrides
         |__exhibits_index.css
```

### New Custom Styles

Ideally, the file should be named after the view that it modifies. One strategy is to use the name of 
the first subdirectory in `app/views` and use it as a subdirectory in `app/assets/stylesheets`. Then name the file
after the rest of the file path like `<subdir>_<partial name>.css`.

For example, we have some custom catalog partials in `app/views/catalog` with the following structure:

```
app/views
  |__catalog
    |__viewers
      |__audio.html.erb
      |__video.html.erb
```

The stylesheets for these files are organized like so:

```
app/assets/stylesheets
  |__catalog
       |__viewers_audio.css
       |__viewers_video.css
```