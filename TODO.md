# Tester feedback

1. Create a short introductory wizard for new users to understand the UI

2. Add an about screen to the menus, and include the privacy policy which will link to the privacy policy on the play store page

3. Edge-to-Edge for Android 15
From Android 15, apps targeting SDK 35 will display edge-to-edge by default. Apps targeting SDK 35 should handle insets to make sure that their app displays correctly on Android 15 and later. Investigate this issue and allow time to test edge-to-edge and make the required updates. Alternatively, call enableEdgeToEdge() for Kotlin or EdgeToEdge.enable() for Java for backward compatibility.

https://developer.android.com/about/versions/15/behavior-changes-15#edge-to-edge