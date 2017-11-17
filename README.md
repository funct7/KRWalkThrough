# KRWalkThrough

[![CI Status](http://img.shields.io/travis/Josh Woomin Park/KRWalkThrough.svg?style=flat)](https://travis-ci.org/Joshua Park/KRWalkThrough)
[![Version](https://img.shields.io/cocoapods/v/KRWalkThrough.svg?style=flat)](http://cocoapods.org/pods/KRWalkThrough)
[![License](https://img.shields.io/cocoapods/l/KRWalkThrough.svg?style=flat)](http://cocoapods.org/pods/KRWalkThrough)
[![Platform](https://img.shields.io/cocoapods/p/KRWalkThrough.svg?style=flat)](http://cocoapods.org/pods/KRWalkThrough)

## 0.11.0 UPDATE

- `TutorialView` can be customized to bypass touch to the underlying view while blocking only certain areas using `makeUnavailable(rect:action:)`. By making the `rect` unavailable and making the whole bounds of the `TutorialView` instance available--specifically in that order--users can touch anywhere except for those areas marked unavailable.
- `TutorialView` can trigger actions without the use of adding buttons as subviews. This is also true for areas that are made available through calling one of the `makeAvailable()` variants, through passing a block as the `action` argument. This obviates one having to add a button to the `TutorialView` instance, and calling a function within the callback and sending a `.touchUpInside` event to the underlying button.

## Note on Swift 3 & iOS 10

For those who are using Swift 2.2-, there is a separate `swift2.2` branch. Or you can choose to checkout `0.9.7`.

For those who have migrated to Swift 3, please read the following.

There seems to be a false memory leak bug in Swift 3 & iOS 10.
What I've found out about this bug so far points me to think that this is not a real memory leak.
To find out more about this, please read this [StackOverflow post](http://stackoverflow.com/questions/39886126/swift-3-ios-10-false-memory-leak-bug).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

KRWalkThrough is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KRWalkThrough"
```

## Author

Josh Woomin Park, wmpark@knowre.com

## License

KRWalkThrough is available under the MIT license. See the LICENSE file for more info.
