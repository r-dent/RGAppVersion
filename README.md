# RGAppVersion
Simple class for accessing the iOS app version and track app updates.

## Installation
Just drag RGAppVersion.swift into your Project.

Or if you´re using [CocoaPods](https://cocoapods.org), add this to your Podfile:

	pod 'RGAppVersion'
	
## Usage

`RGAppVersion.currentVersion()` gives you the current version of the app.
`RGAppVersion.lastVersion()` gives you the version of the app at last launch.
	
	// Print the current installed app version.
	print(RGAppVersion.currentVersion().combinedVersion)
	
	// Print the last installed app version.
	print(RGAppVersion.lastVersion())
	
	// React on a new installation.
	if RGAppVersion.appIsFreshInstalled() {
        print("New installation")
    }
    
    // React on app update.
    if RGAppVersion.appWasUpdated() {
        print("App update from \(RGAppVersion.lastVersion()!.combinedVersion) to \(RGAppVersion.currentVersion().combinedVersion)")
    }

Keep in mind that when you´re using RGAppVersion for the first time, it will always recognize a fresh installation. 