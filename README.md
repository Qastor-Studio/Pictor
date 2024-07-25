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

### selectionColor
`selectionColor: Color` determines what color the symbol will have when it is on selection.

Default as `Color.accentColor`

### aboutLinkIsHidden
`aboutLinkIsHidden: Bool` tells if the about link should be hidden or not.

Please use `PictorAboutView()` to add a link to the About page if you hide it.

Default as `false`

### label
`label: () -> L` recieves a view for the picker's label.

Default as `Text("Pictor")`

### onSubmit
`onSubmit: () -> Void` receives actions and will be run when the sheet is closed.

This works like `onSubmit` in the native SwiftUI.

Default as `{}` (runs nothing when submit)

## Pictor Emoji Picker
```swift
PictorEmojiPicker(emoji: $emoji,
                   aboutLinkIsHidden: false,
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

## Credits
- ThreeManager785
- WindowsMEMZ
