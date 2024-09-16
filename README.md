# Pictor
A SF Symbol &amp; Emoji Picker in SwiftUI for watchOS

![:name](https://counter.seku.su/cmoe?name=Garden785-Pictor&theme=r34)

You may want to allow user to pick a symbol of an emoji for something like your folder icon or what else.

Pictor allows users to pick symbol or emoji they like.

## Features
- SF Symbols
  - Smart search
  - Localizations
  - Restriction tips
  - Backward compatibility
  - Smart sort
  - Organized
- Emojis
  - Groups & Subgroups
  - Quick Browse
 
## Pictor Symbol Picker
```swift
PictorSymbolPicker(symbol: $symbol,
                   presentAsSheet: false,
                   selectionColor: Color.blue,
                   aboutLinkIsHidden: false,
                   label: {
                       Text("Pictor")
                   }, onSubmit: {
                       print("Submitted!")
})
```

### symbol
`symbol: Binding<String>` indicates the symbol name.

### presentAsSheet
`presentAsSheet: Bool` can make the picker into a button that pops up a sheet on tap.

Default as `false`

### selectionColor
`selectionColor: Color` determines what color the symbol will have when it is on selection.

Default as `Color.accentColor`

### aboutLinkIsHidden
`aboutLinkIsHidden: Bool` tells if the about link should be hidden or not.

Please use `PictorAboutView()` to add a link to the About page if you hide it.

Default as `false`

### label
`label: () -> L` recieves a view for the picker's label.

Default as `HStack{Text("Pictor");Spacer()}`

### onSubmit
`onSubmit: () -> Void` receives actions and will be run when the sheet is closed.

This works like `onSubmit` in the native SwiftUI.

Default as `{}` (runs nothing when submit)

## Pictor Emoji Picker
```swift
PictorEmojiPicker(emoji: $emoji,
                   aboutLinkIsHidden: false,
                   presentAsSheet: false,
                   label: {
                      Text("Pictor")
                   }, onSubmit: {
                      print("Submitted!")
})
```

### emoji
`symbol: Binding<String>` indicates the emoji.

We do not recommend inputting String that is longer than a character.

### Other Parameters
They are 100% same with `PictorSymbolPictor`, except `PictorEmojiPictor` does not have `selectionColor: Color`.

## Usage
If `aboutLinkIsHidden` is set to `true` (default as `false`), then you need to add one of these caption below to your project. The caption could be placed at anywhere as long as it is not hard to be found.

> Powered by Pictor

or

> Powered by Garden Pictor


## Credits
- ThreeManager785
- WindowsMEMZ
