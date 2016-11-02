//  Copyright (c) 2016 Roman Gille, http://romangille.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

open class RGAppVersion {
    /**
        The current installation state of the app.
     
        - NotDetermined: The current state is not determined. Run determineAppVersionState() to fix this.
        - Installed: The app was fresh installed. This could also mean that you´ve run the app with RGAppVersion for the first time.
        - Updated: The app ws launched after an update.
        - NothingChanged: The app was just launched regular.
    */
    enum RGAppVersionState {
        case notDetermined, installed, updated, nothingChanged
    }
    
    fileprivate static let lastInstalledAppVersionKey = "rg.appVersion.lastInstalledAppVersion"
    fileprivate static let lastInstalledBuildKey = "rg.appVersion.lastInstalledAppversion"
    
    fileprivate static var _lastInstalledAppVersion: RGAppVersion?
    fileprivate static var _currentAppVersion: RGAppVersion?
    fileprivate static var _appVersionState = RGAppVersionState.notDetermined
    
    /// The version string app.
    open var appVersion: String?
    /// The build number string.
    open var buildNumber: String?
    
    /// A combination of version and build. Like 1.7(47).
    open var combinedVersion: String {
        get {
            if let appVersion = appVersion, let buildNumber = buildNumber {
                return "\(appVersion)(\(buildNumber))"
            }
            return ""
        }
    }
    
    class var defaults: UserDefaults {get {return UserDefaults.standard}}
    
    /**
        Initializer.
        
        - Parameter appVersion: The app version string.
        - Parameter buildNumber: The build number string.
    */
    public init(appVersion: String?, buildNumber: String?) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
    
    /**
        Saves the values of the RGAppVersion object to user defaults.
    */
    func setAsCurrentVersion() {
        RGAppVersion.defaults.set(appVersion, forKey: RGAppVersion.lastInstalledAppVersionKey)
        RGAppVersion.defaults.set(buildNumber, forKey: RGAppVersion.lastInstalledBuildKey)
        RGAppVersion.defaults.synchronize()
    }
    
    /**
        Gets app version and bundle identifier from bundle and user defaults and determines 
        the current installation state by comparing them.
     
        This also saves the current app version to the user defaults.
    */
    open class func determineAppVersionState() {
        if _appVersionState != .notDetermined {
            return
        }
        
        _currentAppVersion = RGAppVersion(
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            buildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        )
        
        _lastInstalledAppVersion = RGAppVersion(
            appVersion: RGAppVersion.defaults.string(forKey: RGAppVersion.lastInstalledAppVersionKey),
            buildNumber: RGAppVersion.defaults.string(forKey: RGAppVersion.lastInstalledBuildKey)
        )
        
        // App fresh installed.
        if _lastInstalledAppVersion?.appVersion == nil {
            _currentAppVersion?.setAsCurrentVersion()
            
            _appVersionState = .installed
        }
        // App updated.
        else if _lastInstalledAppVersion?.combinedVersion != _currentAppVersion?.combinedVersion {
            _currentAppVersion?.setAsCurrentVersion()
            
            _appVersionState = .updated
        }
        // Nothing changed.
        else {
            _appVersionState = .nothingChanged
        }
    }
    
    /**
        The current version of the app.
     
        - Returns: A combination of app version and build number.
    */
    open class func currentVersion() -> RGAppVersion {
        if _appVersionState == .notDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _currentAppVersion!
    }
    
    /**
        The version, with witch the app was started the last time.
        
        - Returns: A combination of app version and build number.
     */
    open class func lastVersion() -> RGAppVersion? {
        if _appVersionState == .notDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return (_lastInstalledAppVersion?.appVersion == nil) ? nil : _lastInstalledAppVersion
    }
    
    /**
        Check if the app was newly installed.
        A true value could also mean that the app was run the first time with RGAppVersion.
     
        - Returns: A boolean value.
    */
    open class func appIsFreshInstalled() -> Bool {
        if _appVersionState == .notDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _appVersionState == .installed
    }
    
    /**
        Check if the app was launched after an update.
     
        - Returns: A boolean value.
    */
    open class func appWasUpdated() -> Bool {
        if _appVersionState == .notDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _appVersionState == .updated
    }
}
