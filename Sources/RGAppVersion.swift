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
    
    enum RGAppVersionState {
        case NotDetermined, Installed, Updated, NothingChanged
    }
    
    private static let lastInstalledAppVersionKey = "rg.appVersion.lastInstalledAppVersion"
    private static let lastInstalledBuildKey = "rg.appVersion.lastInstalledAppversion"
    
    private static var _lastInstalledAppVersion: RGAppVersion?
    private static var _currentAppVersion: RGAppVersion?
    private static var _appVersionState = RGAppVersionState.NotDetermined
    
    public var appVersion: String?
    public var buildNumber: String?
    
    public var combinedVersion: String {
        get {
            if let appVersion = appVersion, buildNumber = buildNumber {
                return "\(appVersion)(\(buildNumber))"
            }
            return ""
        }
    }
    
    class var defaults: NSUserDefaults {get {return NSUserDefaults.standardUserDefaults()}}
    
    public init(appVersion: String?, buildNumber: String?) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
    
    func setAsCurrentVersion() {
        RGAppVersion.defaults.setObject(appVersion, forKey: RGAppVersion.lastInstalledAppVersionKey)
        RGAppVersion.defaults.setObject(buildNumber, forKey: RGAppVersion.lastInstalledBuildKey)
        RGAppVersion.defaults.synchronize()
    }
    
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
    
    public class func currentVersion() -> RGAppVersion {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _currentAppVersion!
    }
    
    public class func lastVersion() -> RGAppVersion? {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return (_lastInstalledAppVersion?.appVersion == nil) ? nil : _lastInstalledAppVersion
    }
    
    public class func appIsFreshInstalled() -> Bool {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _appVersionState == .Installed
    }
    
    public class func appWasUpdated() -> Bool {
        if _appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _appVersionState == .Updated
    }
}
