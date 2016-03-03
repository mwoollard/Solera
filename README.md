###General
Have tried to stick to the 2-3 hour time window to produce a solution so most basic of UI and could expand on testing, error handling etc with more time. I also didn't use any 3rd party libraries although I usually do, for example Alamofire, SwiftyJSON and RxSwift. The latter with some extensions of my own to aid the MVVM model and binding between the VM and View layer controls.

###Architecture
Separation of layers which I've shown here, so service layer for network access, view model for presenting data for user facing interaction, and view controllers to present that to the user.

Use of protocols to define data types and services so easy to switch in different implementations and support testing.

MVVM architecture to provide clean separation between data to be presented to the user and the way in which it is presented.

###To-do for production
Some things that would be addressed for production version (outside of the very minimal UI!)

* Localisation of all strings
* Interpreting ErrorType to display more informative errors
* UI testing / testing of view controllers
* Logging system with file output
* Testing of currency service with NSURLProtocol to provide mocked out responses to network requests / ability to test network/backend service failure states easily etc
* Analytics
* Crash reporting
* Upload of log files for support
