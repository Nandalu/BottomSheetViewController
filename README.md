# BottomSheetViewController

[![CI Status](https://img.shields.io/travis/Nandalu/BottomSheetViewController.svg?style=flat)](https://travis-ci.org/Nandalu/BottomSheetViewController)
[![Version](https://img.shields.io/cocoapods/v/BottomSheetViewController.svg?style=flat)](https://cocoapods.org/pods/BottomSheetViewController)
[![License](https://img.shields.io/cocoapods/l/BottomSheetViewController.svg?style=flat)](https://cocoapods.org/pods/BottomSheetViewController)
[![Platform](https://img.shields.io/cocoapods/p/BottomSheetViewController.svg?style=flat)](https://cocoapods.org/pods/BottomSheetViewController)



## Requirements

iOS 10 or later

## Installation

### CocoaPods

#### Podfile

```
pod 'BottomSheetViewController'
```

Run `pod install`.

### Carthage

#### Cartfile

```
github "Nandalu/BottomSheetViewController"
```

Follow instructions on [Carthage](https://github.com/Carthage/Carthage).

### Git Submodule

Add as submodule and clone:

```
git submodule add https://github.com/Nandalu/BottomSheetViewController
```

Then manually add to your project, as follows:

### Manually

#### Dependency Project

1. Drag `BottomSheetViewController.xcodeproj` into your project.
2. Project settings - Targets - General - Embedded Binaries: add `BottomSheetViewController.frameworkiOS`

#### Source Code

Or just drag `BottomSheetViewController.swift` into your project.

## License

`BottomSheetViewController.swift` is available under the MPLv2 license. That means, do not directly inject you app logic into it. Use properties and delegate methods it offers. We believe this will lead to better app architecture and framework developement.

Check out Example project, which is available under MIT license.