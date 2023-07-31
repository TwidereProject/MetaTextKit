# MetaTextView

## v2 Specification

The v2 framework using the iOS TextKit 1 to render the text with attributes. For example, the inline emoji attachment and user mention and URL link highlight.

#### MetaLabel
The `MetaLabel` is a subclass of `UILabel` which overrides the `drawText(in:)` method to using custom TextKit stack to draw the text. The label supports display meta content and auto sizing for multiple-lines. 

#### MetaText
The `MetaText` is a class grouping the TextKit stack and contains a `UITextView` constructed base on the stack. This text view allows selection or editing. The component supports self-sizing and appearance customise.

#### Meta
The parser working for two meta source: `Twitter` and `Mastodon`. And anyother meta source could be added by adopt the protocol. Also, folk to support any other meta source is convenient.


## License
MIT