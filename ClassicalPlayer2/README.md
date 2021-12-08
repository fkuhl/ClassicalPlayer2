# ClassicalPlayer2

A Mac Catalyst version of ClassicalPlayer.

Thus the project was created as an iOS project, rather than multi-platform,
then Mac support was added to the iOS target.

UI is completely rewritten in SwiftUI 2, so much better use is made of the 
iPad. Assumes iOS 14, macOS 11.

As of build 12 (macOS 12.0.1), I have no intention of indicating that the app can run under
macOS, because the interface to the system music player is unsably unreliable under MacCatalyst.

Added NSAppleMusicUsageDescription key to info.plist.
