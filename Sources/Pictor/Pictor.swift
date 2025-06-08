// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Foundation

var screenWidth: CGFloat {
  #if os(watchOS)
  WKInterfaceDevice.current().screenBounds.size.width
  #else
  UIApplication.shared.keyWindow!.bounds.width
  #endif
}
var screenHeight: CGFloat {
  #if os(watchOS)
  WKInterfaceDevice.current().screenBounds.size.height
  #else
  UIApplication.shared.keyWindow!.bounds.height
  #endif
}
let languageCode = Locale.current.language.languageCode
let countryCode = Locale.current.region!.identifier
var systemVersion: String {
  #if os(watchOS)
  WKInterfaceDevice.current().systemVersion
  #else
  UIDevice.current.systemVersion
  #endif
}

public struct PictorSymbolPicker<L: View>: View {
  public var symbol: Binding<String>
  public var presentAsSheet: Bool
  public var selectionColor: Color
  public var aboutLinkIsHidden: Bool
  public var label: () -> L
  public var onSubmit: () -> Void = {}
  public init(symbol: Binding<String>, presentAsSheet: Bool = false, selectionColor: Color = Color.accentColor, aboutLinkIsHidden: Bool = false, label: @escaping () -> L = {HStack{Text("Pictor");Spacer()}}, onSubmit: @escaping () -> Void = {}) {
    self.symbol = symbol
    self.presentAsSheet = presentAsSheet
    self.selectionColor = selectionColor
    self.aboutLinkIsHidden = aboutLinkIsHidden
    self.label = label
    self.onSubmit = onSubmit
  }
  @State var isSheetDisplaying = false
  public var body: some View {
    if presentAsSheet {
      Button(action: {
        isSheetDisplaying = true
      }, label: {
        label()
      })
      .sheet(isPresented: $isSheetDisplaying, content: {
        NavigationStack {
          PictorSymbolMainView(symbol: symbol, selectionColor: selectionColor, aboutLinkIsHidden: aboutLinkIsHidden)
          #if os(iOS)
            .toolbar {
              ToolbarItem(placement: .topBarLeading) {
                if #available(iOS 17.0, *) {
                  Button("Dismiss", systemImage: "xmark") {
                    isSheetDisplaying = false
                  }
                  .buttonStyle(.bordered)
                  .buttonBorderShape(.circle)
                  .labelStyle(.iconOnly)
                  .bold()
                  .foregroundStyle(.gray)
                } else {
                  Button("Dismiss", systemImage: "xmark") {
                    isSheetDisplaying = false
                  }
                  .buttonStyle(.bordered)
                  .buttonBorderShape(.roundedRectangle(radius: 1000))
                  .labelStyle(.iconOnly)
                  .bold()
                  .foregroundStyle(.gray)
                }
              }
            }
          #endif
            .onDisappear {
              onSubmit()
            }
        }
      })
    } else {
      NavigationLink(destination: {
        PictorSymbolMainView(symbol: symbol, selectionColor: selectionColor, aboutLinkIsHidden: aboutLinkIsHidden)
          .onDisappear {
            onSubmit()
          }
      }, label: {
        label()
      })
    }
  }
}

public struct PictorEmojiPicker<L: View>: View {
  public var emoji: Binding<String>
  public var presentAsSheet: Bool
  public var aboutLinkIsHidden: Bool
  public var label: () -> L
  public var onSubmit: () -> Void = {}
  public init(emoji: Binding<String>, presentAsSheet: Bool = false, aboutLinkIsHidden: Bool = false, label: @escaping () -> L = {HStack{Text("Pictor");Spacer()}}, onSubmit: @escaping () -> Void = {}) {
    self.emoji = emoji
    self.presentAsSheet = presentAsSheet
    self.aboutLinkIsHidden = aboutLinkIsHidden
    self.label = label
    self.onSubmit = onSubmit
  }
  @State var isSheetDisplaying = false
  public var body: some View {
    NavigationStack {
      if presentAsSheet {
        Button(action: {
          isSheetDisplaying = true
        }, label: {
          label()
        })
        .sheet(isPresented: $isSheetDisplaying, content: {
          NavigationStack {
            PictorEmojiMainView(emoji: emoji, aboutLinkIsHidden: aboutLinkIsHidden)
            #if os(iOS)
              .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                  if #available(iOS 17.0, *) {
                    Button("Dismiss", systemImage: "xmark") {
                      isSheetDisplaying = false
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .labelStyle(.iconOnly)
                    .bold()
                    .foregroundStyle(.gray)
                  } else {
                    Button("Dismiss", systemImage: "xmark") {
                      isSheetDisplaying = false
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 1000))
                    .labelStyle(.iconOnly)
                    .bold()
                    .foregroundStyle(.gray)
                  }
                }
              }
            #endif
              .onDisappear {
                onSubmit()
              }
          }
        })
      } else {
        NavigationLink(destination: {
          PictorEmojiMainView(emoji: emoji, aboutLinkIsHidden: aboutLinkIsHidden)
            .onDisappear {
              onSubmit()
            }
        }, label: {
          label()
        })
      }
    }
  }
}


struct PictorSymbolMainView: View {
  @Binding var symbol: String
  @State var currentGroupSymbols: [String] = []
  @State var searchContent = ""
  var selectionColor: Color
  var aboutLinkIsHidden = false
  let symbolHeightPadding: CGFloat = 1
  var body: some View {
    List {
      if #unavailable(iOS 17, watchOS 10) {
        PictorDetailsView(symbol: $symbol)
      }
      ForEach(0..<symbolGroups.count, id: \.self) { group in
        NavigationLink(destination: {
          ScrollView {
            if group == 0 {
              TextField(String(localized: "Search.field", bundle: Bundle.module), text: $searchContent)
                .onChange(of: searchContent, perform: { value in
                  currentGroupSymbols = getGroupSymbols("", searchContent: searchContent.lowercased())
                })
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
              #if os(iOS)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
              #endif
              Group {
                if currentGroupSymbols.isEmpty && !searchContent.isEmpty {
                  Text(String(localized: "Search.none", bundle: Bundle.module))
                } else if currentGroupSymbols.isEmpty {
                  Text(String(localized: "Search.waiting", bundle: Bundle.module))
                }
              }
              .padding(.top, 10)
              .foregroundStyle(.secondary)
              .font(.title3)
              .bold()
            }
            #if os(watchOS)
            let gridColumnCount = 4
            let symbolWidthSpacing: Double = 8
            #else
            let gridColumnCount = 6
            let symbolWidthSpacing: Double = 10
            #endif
            LazyVGrid(columns: .init(repeating: .init(.flexible()), count: gridColumnCount)) {
              ForEach(0..<currentGroupSymbols.count, id: \.self) { symbolIndex in
                Group {
                  if !currentGroupSymbols.isEmpty {
                    Button(action: {
                      symbol = currentGroupSymbols[symbolIndex]
                    }, label: {
                      Image(systemName: arraySafeAccess(currentGroupSymbols, element: symbolIndex) ?? "")
                        .font(.system(size: screenWidth/symbolWidthSpacing))
                    })
                    .buttonStyle(.plain)
                    .foregroundStyle(currentGroupSymbols[symbolIndex] == symbol ? selectionColor : .primary)
                  }
                }
                .padding(.vertical, symbolHeightPadding)
              }
            }
            #if os(iOS)
            .padding()
            #endif
          }
          .navigationTitle(Text(group != 0 ? symbolGroups[group].0 : (LocalizedStringResource("Search.title", bundle: .atURL(Bundle.module.bundleURL)))))
          .onAppear {
            if group != 0 {
              currentGroupSymbols = getGroupSymbols(symbolGroups[group].1)
            } else {
              currentGroupSymbols = getGroupSymbols("", searchContent: searchContent.lowercased())
            }
          }
          .toolbar {
            if #available(iOS 17, watchOS 10, *) {
              ToolbarItem(placement: .topBarTrailing, content: {
                PictorDetailsView(symbol: $symbol)
                  .contentTransition(.symbolEffect(.replace))
              })
            }
          }
        }, label: {
          HStack {
            Label {
              Text(symbolGroups[group].0)
            } icon: {
              Image(systemName: symbolGroups[group].2)
            }
            Spacer()
          }
        })
      }
    }
    .navigationTitle(String(localized: "Group.title", bundle: Bundle.module))
    .onAppear {
    }
    .toolbar {
      if #available(iOS 17, watchOS 10, *) {
        ToolbarItem(placement: .topBarTrailing, content: {
          PictorDetailsView(symbol: $symbol)
            .contentTransition(.symbolEffect(.replace))
        })
      }
    }
  }
}

struct PictorEmojiMainView: View {
  @Binding var emoji: String
  var aboutLinkIsHidden = false
  @State var aboutLinkIsShwon = false
  let emojiHeightPadding: CGFloat = 1
  var body: some View {
    List {
      if #unavailable(watchOS 10) {
        HStack {
          Text(String(localized: "Current.emoji.\(emoji)", bundle: Bundle.module))
          Spacer()
        }
      }
      ForEach(0..<emojiGroupNames.count, id: \.self) { group in
        if group != 2 {
          NavigationLink(destination: {
            List {
              #if os(watchOS)
              let gridColumnCount = 4
              let emojiWidthSpacing: Double = 6
              #else
              let gridColumnCount = 6
              let emojiWidthSpacing: Double = 10
              #endif
              ForEach(0..<emojiDictionary[group].count, id: \.self) { subgroup in
                Section(content: {
                  LazyVGrid(columns: .init(repeating: .init(.flexible()), count: gridColumnCount)) {
                    ForEach(0..<hideTaiwanFlag(emojiDictionary[group][subgroup]).count, id: \.self) { emojiIndex in
                      Group {
                        Button(action: {
                          emoji = hideTaiwanFlag(emojiDictionary[group][subgroup])[emojiIndex]
                        }, label: {
                          Text(arraySafeAccess(hideTaiwanFlag(emojiDictionary[group][subgroup]), element: emojiIndex) ?? "")
                            .font(.system(size: screenWidth/emojiWidthSpacing))
                        })
                        .buttonStyle(.plain)
                      }
                      .padding(.vertical, emojiHeightPadding)
                    }
                  }
                }, header: {
                  HStack {
                    Text(emojiSubgroupNames[group+1]![subgroup])
                      .font(.caption)
                      .fontWeight(.medium)
                    //                        .fontWeight(.light)
                    Spacer()
                  }
                  .padding(.horizontal, 3)
                })
                #if os(watchOS)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                #endif
              }
            }
            .navigationTitle(Text(emojiGroupNames[group+1]!))
            .toolbar {
              if #available(watchOS 10, *) {
                ToolbarItem(placement: .topBarTrailing, content: {
                  Button(action: {
                    aboutLinkIsShwon = !aboutLinkIsHidden
                  }, label: {
                    Text(emoji)
                  })
                })
              }
            }
          }, label: {
            HStack {
              Text(emojiGroupExamples[group+1]!)
              Text(emojiGroupNames[group+1]!)
              Spacer()
            }
          })
        }
      }
    }
    .navigationTitle(String(localized: "Group.title", bundle: Bundle.module))
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItem(placement: .topBarTrailing, content: {
          Button(action: {
            aboutLinkIsShwon = !aboutLinkIsHidden
          }, label: {
            Text(emoji)
          })
        })
      }
    }
    .sheet(isPresented: $aboutLinkIsShwon, content: {
      PictorAboutView()
    })
  }
}

struct PictorDetailsView: View {
  @Binding var symbol: String
  @State var localizationBody: String = ""
  @State var localizationSuffix: String = ""
  let symbolsRestrictions = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "symbol_restrictions", withExtension: "plist")!), format: nil) as! [String: String]
  var body: some View {
    NavigationLink(destination: {
      ScrollView {
        VStack(alignment: .leading) {
          HStack {
            Image(systemName: symbol)
              .font(.title)
            Text(symbol)
              .bold()
              .monospaced()
            Spacer()
          }
          if symbolsRestrictions[localizationBody] != nil {
            Divider()
            Text(String(localized: "Details.restrictions", bundle: Bundle.module))
              .bold()
            Text(symbolsRestrictions[localizationBody]!)
              .font(.caption2)
            if !(languageCode!.identifier).contains("en") {
              Text(restrictionsLocalized[symbolsRestrictions[localizationBody]!]!)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
          }
          if #available(watchOS 11, *) {
            if symbolsWithLocalizations[localizationBody] != nil {
              Divider()
              Text(String(localized: "Details.localization", bundle: Bundle.module))
                .bold()
              NavigationLink(destination: {
                List {
                  Section {
                    Button(action: {
                      localizationSuffix = ""
                      symbol = localizationBody
                    }, label: {
                      HStack {
                        Image(systemName: localizationBody)
                        Text(String(localized: "Details.localization.default", bundle: Bundle.module))
                        Spacer()
                        if localizationSuffix == "" {
                          Image(systemName: "checkmark")
                        }
                      }
                    })
                    //                    Button(action: {}, label: {
                    //                      HStack {
                    //                        Image(systemName: localizationBody)
                    //
                    //                        Text(String(localized: "Details.localization.standard", bundle: Bundle.module))
                    //                        Spacer()
                    //                      }
                    //                      .foregroundStyle(.secondary)
                    //                      .environment(\.locale, .init(identifier: "en"))
                    //                    })
                  }
                  Section {
                    if symbolsWithLocalizations[localizationBody] != nil {
                      ForEach(0..<symbolsWithLocalizations[localizationBody]!.count, id: \.self) { index in
                        Button(action: {
                          localizationSuffix = symbolsWithLocalizations[localizationBody]![index]
                          symbol = localizationBody + "." + localizationSuffix
                          print(localizationSuffix)
                        }, label: {
                          HStack {
                            Image(systemName: localizationBody + "." + symbolsWithLocalizations[localizationBody]![index])
                            Text(scriptsLocalized[symbolsWithLocalizations[localizationBody]![index]]!)
                            Spacer()
                            if localizationSuffix == symbolsWithLocalizations[localizationBody]![index] {
                              Image(systemName: "checkmark")
                            }
                          }
                        })
                      }
                    }
                  }
                }
                .navigationTitle(String(localized: "Localization", bundle: Bundle.module))
              }, label: {
                HStack {
                  Image(systemName: localizationBody)
                    .environment(\.locale, .init(identifier: "en"))
                  Text(String(localized: "Details.localization.\(symbolsWithLocalizations[localizationBody]!.count)", bundle: Bundle.module))
                  Spacer()
                }
              })
              .buttonBorderShape(.roundedRectangle)
            }
          }
          if symbolsWithLocalizations[localizationBody] == nil && symbolsRestrictions[localizationBody] == nil {
            Section {
              Divider()
              Text(String(localized: "Details.none", bundle: Bundle.module))
                .bold()
                .foregroundStyle(.secondary)
            }
          }
        }
        #if os(iOS)
        .padding()
        #endif
      }
      .onAppear {
        if symbol.hasSuffix(".rtl") || symbol.hasSuffix(".ar") || symbol.hasSuffix(".el") || symbol.hasSuffix(".he") || symbol.hasSuffix(".hi") || symbol.hasSuffix(".ja") || symbol.hasSuffix(".ko") || symbol.hasSuffix(".ru") || symbol.hasSuffix(".th") || symbol.hasSuffix(".zh") || symbol.hasSuffix(".el") || symbol.hasSuffix(".my") || symbol.hasSuffix(".km") || symbol.hasSuffix(".bn") || symbol.hasSuffix(".gu") || symbol.hasSuffix(".pa") || symbol.hasSuffix(".te") || symbol.hasSuffix(".ml") || symbol.hasSuffix(".or") || symbol.hasSuffix(".kn") || symbol.hasSuffix(".sat") || symbol.hasSuffix(".mnl")  {
          localizationBody = String(symbol.dropLast((symbol.hasSuffix(".rtl") || symbol.hasSuffix(".sat") || symbol.hasSuffix(".mnl")) ? 4 : 3))
          localizationSuffix = String(symbol.split(separator: ".").last!)
        } else {
          localizationBody = symbol
          localizationSuffix = ""
        }
      }
      .navigationTitle(String(localized: "Details", bundle: Bundle.module))
      .toolbar {
        if #available(watchOS 10, *) {
          ToolbarItem(placement: .topBarTrailing, content: {
            NavigationLink(destination: {
              PictorAboutView()
            }, label: {
              Image(systemName: "info")
            })
          })
        }
      }
    }, label: {
      if #available(iOS 17, watchOS 10, *) {
        Image(systemName: symbol)
      } else {
        HStack {
          Text(String(localized: "Current.symbol", bundle: Bundle.module))
          Image(systemName: symbol)
          Spacer()
        }
      }
    })
  }
}

public struct PictorAboutView: View {
  public var body: some View {
    NavigationStack {
      List {
        Group {
          HStack {
            Spacer()
            VStack(alignment: .center) {
              Text(verbatim: "Pictor")
                .bold()
                .font(.title2)
              Group {
                Text(verbatim: "By Serene Garden")
                Text(verbatim: PictorVersion)
                  .monospaced()
              }
              //        .foregroundStyle(.secondary)
              .font(.caption)
            }
            Spacer()
          }
        }
        .listRowBackground(Rectangle().opacity(0).frame(height: 0))
        Section {
          NavigationLink(destination: {
            List {
              Section(content: {
                Text(verbatim: "ThreeManager785")
                Text(verbatim: "WindowsMEMZ")
              }, footer: {
                Text(verbatim: "https://github.com/Serene-Garden/Pictor")
              })
            }
          }, label: {
            HStack {
              if #available(iOS 16.1, watchOS 9.1, *) {
                Image(systemName: "fleuron")
                  .font(.system(size: 20))
                  .foregroundStyle(.tint)
                  .fontDesign(.rounded)
              } else {
                Image(systemName: "fleuron")
                  .font(.system(size: 20))
                  .foregroundStyle(.tint)
              }
              VStack(alignment: .leading) {
                Text(String(localized: "Pictor.credits", bundle: Bundle.module))
              }
            }
          })
        }
      }
    }
    .onAppear {
      //        for (key, value) in symbolsAvailability {
      //          print("<key>\(key)</key>")
      //          print("<string>\(value)</string>")
      //        }
    }
    //      .onAppear {
    //        let symbolsOrder = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "name_aliases", withExtension: "plist")!), format: nil) as! [String: String]
    //        var output: [String: String] = [:]
    //        for (key, value) in symbolsOrder {
    //          if output[value] == nil {
    //            output.updateValue(key, forKey: value)
    //          }
    //////            output[value]?.append(key)
    ////          }
    //        }
    //        print(output)
    //      }
    //      .onAppear {
    //        let symbolAvailability = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "name_availability", withExtension: "plist")!), format: nil) as! [String: [String: Any]]
    ////        print(type(of: symbolAvailability))
    //        var symbolsNames = symbolAvailability["symbols"] as! [String: String]
    //        let symbolsYears = symbolAvailability["year_to_release"] as! [String: [String: String]]
    //        var yearsToReplace: [String: String] = [:]
    //        var yearsKey: [String] = []
    //        for (key, value) in symbolsYears {
    //          yearsKey.append(key)
    //          yearsToReplace.updateValue(value["watchOS"]!, forKey: key)
    //        }
    ////        print(yearsToReplace)
    ////        print(symbolsNames)
    //        symbolsNames.map { key, value in (key, Double(value)!) }
    //        var trueOutput = symbolsNames.description
    //        for i in 0..<yearsKey.count {
    //          trueOutput.replace(yearsKey[i], with: yearsToReplace[yearsKey[i]]!)
    //        }
    //        print(trueOutput)
    ////        print(yearsKey)
    ////        print(trueOutput)
    ////        let symbolsNames = symbolAvailability.0
    ////        let symbolsYears = symbolAvailability.1
    //      }
  }
}

func getGroupSymbols(_ groupName: String, searchContent: String? = nil) -> [String] {
  let symbolsOrder = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "symbol_order", withExtension: "plist")!), format: nil) as! [String]
  var output: [String] = []
  var searchKeys: [String] = []
  //  var printer: [String: [String]] = [:]
  if searchContent != nil && !searchContent!.isEmpty {
    searchKeys = searchContent!.components(separatedBy: " ")
    output = symbolsOrder
    for index in 0..<searchKeys.count {
      output = output.filter {
        $0.contains(searchKeys[index]) || ((symbolsSearchAssociation[searchKeys[index]] ?? []).contains($0))
      }
    }
  } else if searchContent != nil && searchContent!.isEmpty {
    output = []
  } else if groupName == "all" {
    output = symbolsOrder
  } else {
    output = symbolsInGroup[groupName] ?? ["questionmark"]
  }
  for index in 0..<output.count {
    if arraySafeAccess(output, element: index) != nil {
      if let localization = symbolsWithLocalizations[output[index]] {
        for removingIndex in 0..<localization.count {
          if output.contains(output[index]+".\(localization[removingIndex])") {
            output.remove(at: output.firstIndex(of: output[index]+".\(localization[removingIndex])")!)
          }
        }
      }
    }
    
  }
  if isGreaterVersion(getResolvedVersionNumber(latestSystemVer), comparingWith: getResolvedVersionNumber(systemVersion), equal: false) {
    let symbolAliases = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "symbol_aliases", withExtension: "plist")!), format: nil) as! [String: String]
    let symbolsAvailability = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "symbol_availability", withExtension: "plist")!), format: nil) as! [String: String]
    var index = -1
    for fakeIndex in 0..<output.count {
      index += 1
      if let symbolVer = symbolsAvailability[arraySafeAccess(output, element: index) ?? ""] {
        if isGreaterVersion(getResolvedVersionNumber(symbolVer), comparingWith: getResolvedVersionNumber(systemVersion), equal: false) {
          if let symbolAlias = symbolAliases[output[index]] {
            if isGreaterVersion(getResolvedVersionNumber(systemVersion), comparingWith: getResolvedVersionNumber(symbolsAvailability[symbolAlias] ?? "1.0"), equal: true) {
              //              output.replace(output[index], with: symbolAlias)
              output[index] = symbolAlias
            } else {
              output.remove(at: index)
              index -= 1
            }
          } else {
            output.remove(at: index)
            index -= 1
          }
        }
      }
    }
  }
  return output
}

func arraySafeAccess<T>(_ array: Array<T>, element: Int) -> T? {
  //This function avoids index out of range error when accessing a range.
  //If out, then it will return nil instead of throwing an error.
  //Normally it will just return the content, but in optional.
  if element >= array.count || element < 0 { //Index out of range
    return nil
  } else { //Index in range
    //    print(array)
    //    print(element)
    return array[element]
  }
}

//func get() {
//  let symbolsSearchKeys = try! PropertyListSerialization.propertyList(from: Data(contentsOf: Bundle.module.url(forResource: "symbol_search", withExtension: "plist")!), format: nil) as! [String: [String]]
//  var organizedDict: [String: [String]] = [:]
//  for (keySymbol, searchableValue) in symbolsSearchKeys {
//    for index in 0..<symbolsSearchKeys[keySymbol]!.count {
//      if organizedDict[searchableValue[index]] == nil {
//        organizedDict.updateValue([keySymbol], forKey: searchableValue[index])
//      } else {
//        organizedDict[searchableValue[index]]!.append(keySymbol)
//      }
//    }
//  }
//  print(organizedDict)
//}

func hideTaiwanFlag(_ array: [String]) -> [String] {
  let taiwanFlag = "🇹🇼"
  if array.contains(taiwanFlag) && countryCode == "CN" {
    var output = array
    output.remove(at: output.firstIndex(of: taiwanFlag)!)
    return output
  } else {
    return array
  }
}

func getResolvedVersionNumber(_ number: String) -> (Int, Int, Int) {
  let numbersBreaked = number.split(separator: ".")
  let header = Int(numbersBreaked[0])
  let body = Int(numbersBreaked[1])
  let trailer = Int(arraySafeAccess(numbersBreaked, element: 2) ?? "0")
  return (header!, body!, trailer!)
}

func isGreaterVersion(_ first: (Int, Int, Int), comparingWith: (Int, Int, Int), equal: Bool = false) -> Bool {
  if first.0 > comparingWith.0 {
    return true
  } else if first.0 < comparingWith.0 {
    return false
  } else {
    if first.1 > comparingWith.1 {
      return true
    } else if first.1 < comparingWith.1 {
      return false
    } else {
      if first.2 > comparingWith.2 {
        return true
      } else if first.2 < comparingWith.2 {
        return false
      } else {
        return equal
      }
    }
  }
}
