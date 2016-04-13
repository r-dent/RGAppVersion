//
//  RGAppVersion.swift
//  AppVersion
//
//  Created by Roman Gille on 13.04.16.
//  Copyright © 2016 Roman Gille. All rights reserved.
//

import Foundation

class RGAppVersion {
    
    enum RGAppVersionState {
        case NotDetermined, Installed, Updated, NothingChanged
    }
    
    static let lastInstalledAppVersionKey = "rg.appVersion.lastInstalledAppVersion"
    static let lastInstalledBuildKey = "rg.appVersion.lastInstalledAppversion"
    
    private static var _lastInstalledAppVersion: RGAppVersion?
    private static var _currentAppVersion: RGAppVersion?
    static var appVersionState = RGAppVersionState.NotDetermined
    
    var appVersion: String?
    var buildNumber: String?
    
    var combinedVersion: String {
        get {
            if let appVersion = appVersion, buildNumber = buildNumber {
                return "\(appVersion)(\(buildNumber))"
            }
            return ""
        }
    }
    
    class var defaults: NSUserDefaults {get {return NSUserDefaults.standardUserDefaults()}}
    
    init(appVersion: String?, buildNumber: String?) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
    
    func setAsCurrentVersion() {
        RGAppVersion.defaults.setObject(appVersion, forKey: RGAppVersion.lastInstalledAppVersionKey)
        RGAppVersion.defaults.setObject(buildNumber, forKey: RGAppVersion.lastInstalledBuildKey)
        RGAppVersion.defaults.synchronize()
    }
    
    class func determineAppVersionState() {
        if appVersionState != .NotDetermined {
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
            
            appVersionState = .Installed
        }
        // App updated.
        else if _lastInstalledAppVersion?.combinedVersion != _currentAppVersion?.combinedVersion {
            _currentAppVersion?.setAsCurrentVersion()
            
            appVersionState = .Updated
        }
        // Nothing changed.
        else {
            appVersionState = .NothingChanged
        }
    }
    
    class func currentVersion() -> RGAppVersion {
        if appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return _currentAppVersion!
    }
    
    class func lastVersion() -> RGAppVersion? {
        if appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return (_lastInstalledAppVersion?.appVersion == nil) ? nil : _lastInstalledAppVersion
    }
    
    class func appIsFreshInstalled() -> Bool {
        if appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return appVersionState == .Installed
    }
    
    class func appWasUpdated() -> Bool {
        if appVersionState == .NotDetermined {
            RGAppVersion.determineAppVersionState()
        }
        return appVersionState == .Updated
    }
}
