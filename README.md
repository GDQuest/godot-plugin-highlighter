# Editor Highlighter

Highlights parts of the editor interface that are under the mouse. Useful for screencasts and the like.


## How to Use

Press <kbd>alt</kbd>+<kbd>h</kbd> to highlight the UI item under the mouse. Release to stop highlighting.


## How to Customize

You can edit the plugin options in project settings. The keys will be under `plugins/highlighter`. Make sure to toggle the "show advanced" option.

Options:

- `min depth`: the minimum depth to highlight. Can help avoid highlighting the UI background (levels 1 to 4).
- `max depth`: the maximum depth to highlight. Can help avoid deeply nested items
- `shortcut`: the shortcut to press
- `highlight`: a path to a `StyleBox` resource which is used to draw the highlight.


## License

MIT (file in [`addons/editor-highlighter/LICENSE`](addons/editor-highlighter/LICENSE))