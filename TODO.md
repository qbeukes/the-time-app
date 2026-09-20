# Tester feedback

* Create a short introductory wizard for new users to understand the app features. This will be a modal wizard that can be invoked from the menu. It will include a brief description of each view (tab) and settings screen. It will also darken the app and highlight the feature being introduced, step by step. The first screen will be invoked by a new "Show Introduction" menu item on the shared 
burger menu. The wizard can be skipped. It is shown on startup until it was either completed or
dismissed but can always be accessed again under Show Introduction

* Edge-to-Edge for Android 15
From Android 15, apps targeting SDK 35 will display edge-to-edge by default. Apps targeting SDK 35 should handle insets to make sure that their app displays correctly on Android 15 and later. Investigate this issue and allow time to test edge-to-edge and make the required updates. Alternatively, call enableEdgeToEdge() for Kotlin or EdgeToEdge.enable() for Java for backward compatibility.

https://developer.android.com/about/versions/15/behavior-changes-15#edge-to-edge