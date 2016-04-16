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

public class RGAppVersion {
    /**
        The current installation state of the app.
     
        - NotDetermined: The current state is not determined. Run determineAppVersionState() to fix this.
        - Installed: The app was fresh installed. This could also mean that you´ve run the app with RGAppVersion for the first time.
        - Updated: The app ws launched after an update.
        - NothingChanged: The app was just launched regular.
    */
    enum RGAppVersionState {
        case NotDetermined, Installed, Updated, NothingChanged
    }
    
    private static let lastInstalledAppVersionKey = "rg.appVersion.lastInstalledAppVersion"
    private static let lastInstalledBuildKey = "rg.appVersion.lastInstalledAppversion"
    
    private static var _lastInstalledAppVersion: RGAppVersion?
    private static var _currentAppVersion: RGAppVersion?
    private static var _appVersionState = RGAppVersionState.NotDetermined
    
    /// The version string app.
    public var appVersion: String?
    /// The build number string.
    public var buildNumber: String?
    
    /// A combination of version and build. Like 1.7(47).
    public var combinedVersion: String {
        get {
            if let appVersion = appVersion, buildNumber = buildNumber {
                return "\(appVersion)(\(buildNumber))"
            }
            return ""
        }
    }
    
    class var defaults: NSUserDefaults {get {return NSUserDefaults.standardUserDefaults()}}
    
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
        RGAppVersion.defaults.setObject(appVersion, forKey: RGAppVersion.lastInstalledAppVersionKey)
        RGAppVersion.defaults.setObject(buildNumber, forKey: RGAppVersion.lastInstalledBuildKey)
        RGAppVersion.defaults.synchronize()
    }
    
    /**
        Gets app version and bundle identifier from bundle and user defaults and determines 
        the current installation state by comparing them.
     
        This also saves the current app version to the user defaults.
    */
    public class func determineAppVersionState() {
        if _appVersionState != .NotDetermined {
            return
        }
        
        _currentAppVersion = RGAppVersion(
            appVersion: NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String,
            buildNumber: NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String
        )
        
        _lastInstalledAppVersion = RGAppVersion(
            appVersion: RGAppVersion.defaults.stringForKey(RGAppVersion.lastInstalledAppVersionKey),
            buildNumber: RGAppVersion.defaults.stringForKey(RGAppVersion.lastInstalledBuildKey)
        )
        
        // App fresh installed.
        if _lastInstalledAppVersion?.appVersion == nil {
            _currentAppVersion?.setAsCurrentVersion()
            
            _appVersionState = .Installed
        }
        // App updated.
        else if _lastInstalledAppVersion?.combinedVersion != _currentAppVersion?.combinedVersion {
            _currentAppVersion?.setAsCurrentVersion()
            
            _appVersionState = .Updated
        }
        // Nothing changed.
        else {
            _appVersionState = .NothingChanged
        }
    }
    
    /**
        The current version of the app.
     
        - Returns: A combination of app version and build number.
    */
    public class func currentVersion() -> RGAppVersion {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _currentAppVersion!
    }
    
    /**
        The version, with witch the app was started the last time.
        
        - Returns: A combination of app version and build number.
     */
    public class func lastVersion() -> RGAppVersion? {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return (_lastInstalledAppVersion?.appVersion == nil) ? nil : _lastInstalledAppVersion
    }
    
    /**
        Check if the app was newly installed.
        A true value could also mean that the app was run the first time with RGAppVersion.
     
        - Returns: A boolean value.
    */
    public class func appIsFreshInstalled() -> Bool {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _appVersionState == .Installed
    }
    
    /**
        Check if the app was launched after an update.
     
        - Returns: A boolean value.
    */
    public class func appWasUpdated() -> Bool {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _appVersionState == .Updated
    }
}
