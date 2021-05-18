//
//  SystemTheme.swift
//  ThemeKit
//
//  Created by Nuno Grilo on 06/09/16.
//  Copyright © 2016 Paw & Nuno Grilo. All rights reserved.
//

import Foundation

/// System theme. 
///
/// Will dynamically resolve to either `ThemeManager.lightTheme` or `ThemeManager.darkTheme`,
/// depending on the macOS preference at **System Preferences > General > Appearance**.
@objc(TKSystemTheme)
public class SystemTheme: NSObject, Theme {

    /// System  theme identifier (static).
    @objc public static var identifier: String = "com.luckymarmot.ThemeKit.SystemTheme"

    /// Unique theme identifier.
    public var identifier: String = SystemTheme.identifier

    /// Theme display name.
    public var displayName: String {
        let systemVersion = OperatingSystemVersion(majorVersion: 10, minorVersion: 12, patchVersion: 0)
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(systemVersion) ? "macOS Theme" : "OS X Theme"
    }

    /// Theme short display name.
    public var shortDisplayName: String {
        return displayName
    }

    /// Is this a dark theme?
    public var isDarkTheme: Bool = SystemTheme.isAppleInterfaceThemeDark

    /// Checks if Apple UI theme is set to dark, as set on **System Preferences > General > Appearance**.
    @objc public static var isAppleInterfaceThemeDark: Bool = SystemTheme.isAppleInterfaceThemeDarkOnUserDefaults()

    /// Calling `init()` is not allowed outside this library.
    /// Use `ThemeManager.systemTheme` instead.
    internal override init() {
        super.init()

        // Observe macOS Apple Interface Theme
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(appleInterfaceThemeDidChange(_:)), name: .didChangeAppleInterfaceTheme, object: nil)
    }

    /// Apple UI Theme has changed.
    @objc func appleInterfaceThemeDidChange(_ notification: Notification) {
        // check after 100ms because OS might not change yet
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isDarkTheme = SystemTheme.isAppleInterfaceThemeDarkOnUserDefaults()
            SystemTheme.isAppleInterfaceThemeDark = strongSelf.isDarkTheme
            NotificationCenter.default.post(name: .didChangeSystemTheme, object: nil)
        }
    }

    /// Read Apple Interface Theme preference from User Defaults.
    private static func isAppleInterfaceThemeDarkOnUserDefaults() -> Bool {
        // Fix Theme with Auto Switch Mode
        // https://github.com/ruiaureliano/macOS-Appearance/issues/1#issuecomment-565610999
        // https://github.com/ruiaureliano/macOS-Appearance/blob/27ef66d9f0e2df054bde5366c878e57575d5b939/Appearance/Source/AppDelegate.swift#L50-L52
        if #available(OSX 10.15, *) {
            let appearanceDescription = NSApplication.shared.effectiveAppearance.debugDescription.lowercased()
            return appearanceDescription.contains("dark")
        }
        else {
            // Default implementation from ThemeKit
            return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") != nil
        }
    }

    override public var description: String {
        return "<\(SystemTheme.self): \(themeDescription(self))>"
    }
}
