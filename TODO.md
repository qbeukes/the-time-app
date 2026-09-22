# Todos

* Moon tilt
  + Rename Developer Features to Advanced Features
  + add tilt to the "Advanced Features"
  
* Time swipe should make the Play button more apparent.
  + Always visible and enabled/disabled if we're ticking or not
  - or add a way to slow down the drag
    - ask Astra for ideas.

* Sun animation
  - brain storm this

* After every update show a popup with the latest version's release notes

* Add contact developer option which will take the person to a contact page on the web site

* Review the tilt's accuracy.

* Create a short introductory wizard for new users to understand the app features. This will be a modal wizard that can be invoked from the menu. It will include a brief description of each view (tab) and settings screen. It will also darken the app and highlight the feature being introduced, step by step. The first screen will be invoked by a new "Show Introduction" menu item on the shared 
burger menu. The wizard can be skipped. It is shown on startup until it was either completed or
dismissed but can always be accessed again under Show Introduction

* Edge-to-Edge for Android 15
From Android 15, apps targeting SDK 35 will display edge-to-edge by default. Apps targeting SDK 35 should handle insets to make sure that their app displays correctly on Android 15 and later. Investigate this issue and allow time to test edge-to-edge and make the required updates. Alternatively, call enableEdgeToEdge() for Kotlin or EdgeToEdge.enable() for Java for backward compatibility.

https://developer.android.com/about/versions/15/behavior-changes-15#edge-to-edge

TEST FEEDBACK
-------------
* Some people asked what the app is about
  - I planned a walkthrough on first open
    - Also add a reset walkthrough button on settings.
  - I want to add a short video describing the luach

* Expert: Tilt function feels awkwardly fast and non-realistic
  - I planned a review to make sure it's accurate according to GPS location 
    - or Locale location if GPS not available
  - Maybe add a 1x/2x/4x/8x/16x to make time pass faster naturally
  - Thinking of making this an "Advanced Feature"

* One tester pointed out some information on the Luach is still inaccurate
  - Founder of bethashem.org who designed the Luach is assisting with advice

* Expert: Swipe feature is too fast 

* One tester didn't notice the play button
  - Expert advised to make it always visible and greyed out instead when not in swipe mode

* Expert: advices to get some effect on the sun
  - Need to brain storm this a bit

* Expert: Pointed out that the cards seem to be clickable but are not
  - The cards should have a click animation for the timebeing, but nothing will happen for now
    - this will just make the UI more beautiful for now
  - Eventually I'll add cards to describe the day in more detail
  
* Someone asked what's the use to the Timer, it seems odd
  - I'll add the moon based time unit to it.