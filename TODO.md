# Tester feedback

* Introduce settings screen
Let's think about the UI for a bit. I want to improve the top navigation bar. The Burger icon is currently use for configuring the current view. Instead I want a menu where or button for an About page or general settings page. Maybe we can make a gear icon that takes over the function of the current menu and the current burger menu show an About, Settings, entries. 

About will contain information about the app, link to web site, link to copyright hosted on the website, link to privacy policy hosted on the web site, a section about the Hypothesis of Time and Change, summarized in 1 paragraph, with a link to the hypothesis on the website. 

Settings will have an "Enable Developer Features" which enables some screen settings be available like "Show Lunar Anchors" toggle, which is disabled by default but with developer features it becomes available to display. It will also have a "Reset to Defaults" which removes all customizations and restores the app settings to their defaults, removing all timer configs as well.

Also feel free to make suggestions and prepare an implementation plan under docs/plans/01_introduce_settings.md. This is a new feature to be explored.

* Put the calendar icon on the navbar on the left after settings were introduced

* Create a short introductory wizard for new users to understand the app features. This will be a modal wizard that can be invoked from the menu. It will include a brief description of each view (tab) and settings screen. It will also darken the app and highlight the feature being introduced, step by step. The first screen will be invoked by a new "Show Introduction" menu item on the shared 
burger menu. The wizard can be skipped. It is shown on startup until it was either completed or
dismissed but can always be accessed again under Show Introduction

* Add an about screen to the menus, and include the privacy policy which will link to the privacy policy on the play store page

* Edge-to-Edge for Android 15
From Android 15, apps targeting SDK 35 will display edge-to-edge by default. Apps targeting SDK 35 should handle insets to make sure that their app displays correctly on Android 15 and later. Investigate this issue and allow time to test edge-to-edge and make the required updates. Alternatively, call enableEdgeToEdge() for Kotlin or EdgeToEdge.enable() for Java for backward compatibility.

https://developer.android.com/about/versions/15/behavior-changes-15#edge-to-edge