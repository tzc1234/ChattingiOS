# ChattingiOS
### I'm curious about how the webSocket works🤔, so I started this project, 1 on 1 chatting💬 app as a practice. It has to run with the server side [here](https://github.com/tzc1234/ChattingServer). 

### Screenshots
<img src="https://github.com/tzc1234/ChattingiOS/blob/main/screenshots/add_contact.jpeg" alt="add_contact" width="256" height="504"/> <img src="https://github.com/tzc1234/ChattingiOS/blob/main/screenshots/contacts.jpeg" alt="contacts" width="256" height="504"/> <img src="https://github.com/tzc1234/ChattingiOS/blob/main/screenshots/search_contacts.jpeg" alt="search_contacts" width="256" height="504"/> <img src="https://github.com/tzc1234/ChattingiOS/blob/main/screenshots/messages.jpeg" alt="messages" width="256" height="504"/> <img src="https://github.com/tzc1234/ChattingiOS/blob/main/screenshots/message_notification.jpeg" alt="message_notification" width="256" height="504"/> <img src="https://github.com/tzc1234/ChattingiOS/blob/main/screenshots/profile.jpeg" alt="profile" width="256" height="504"/>

### Retrospective
#### Use UITableViewRepresentable for messages page
Due to the complexity of the messages page, I would like to have a more fine-grained control (for example the scroll.) of the list of message bubbles. The SwiftUI list does not provide an API for controlling the content offset y (at least not in iOS 17). Therefore, I switch to UITableView, controlling the offset y for accurate keyboard height adjustment.

#### Re-render message bubble after edit message
After the message is edited, if bubbles increase lines of text (to become "taller"), the message bubble view will not expand vertically correctly. I think it's the list row height calculation issue of SwiftUI `List`. It's time to use the good old trick, change the id of the view (use `.id()` modifier), and force SwiftUI to recreate it.

#### Unify the binary for web socket
Before, the read messages endpoint was using HTTP request, now using web socket to read messages. Since the read message request only contains one `untilMessageID` parameter, it is lightweight enough to utilise webSocket for fast, efficient transfer. But then the binary for web socket must be reorganised, unifying from different heartbeat, message, readMessage binary responses to one `MessageChannelBinary`. In order to distinguish the binary data, the first byte(UInt8) is used to determine the response type, and the remaining bytes are the payload. For heartbeat is 0, message is 1, and readMessages is 2, represented by an enum. This approach will also benefit for the future when more different binary data types are needed.

#### Apply new UI design
It's quite easy to update the UI, benefit from the MVVM, I only have to focus on the UI layout/logic. First add the new UI view components files, then wire them to the existing `View Models`, after that with some polishing and bug fixing, finally remove the old views. This time I've extracted the styles code to a separate file. It will be simple to modify or add a new colour theme to this app.

#### Decorators
Briefly introduce this app's structure, the route of get contacts:

`ContactListViewModel` calls -> `GetContacts` protocol <- implemented by `DefaultGetContacts` use case.

After using the decorator for caching, the route become:

`ContactListViewModel` calls -> `GetContacts` protocol <- implemented by `GetContactsWithCacheDecorator` uses -> `DefaultGetContacts` and `CacheContacts`.

Benefit from the decorator pattern, I can intercept the `contacts` data from `DefaultGetContacts`, then cache it by `CacheContacts` without bothering with the `ContactListViewModel`. This approach is much cleaner and easier to understand, in my opinion, to prevent a "massive view model" issue. Also conform to the "Open Close Principle", avoid touching the code in view models. It is not always that easy to add features without modifications, however, with decorators, I can still lessen the changes of existing code.

Refresh token is also done by the decorator. Similar approach: 
1. intercept the error 401 status code after a network API call, by decorator
2. trigger refresh token
3. after a new access token received, call again the same network API
4. the clients do not have to change anything

#### Push Notification
The default push notification handling is easy and straightforward on the app side, and I've utilised `VaporAPNS` for the back-end to send APNS requests. I don't encounter any big issues on implementation, until I want to update my default push notification to communication notification(the notification with an avatar which WhatsApp uses)... I've followed the Apple official doc, adding `NotificationServiceExtension`, importing `Intents`, referencing the sample code from google/AI, still couldn't nail it! After hours and hours of trial and error, I finally discovered I was missing the setting `INSendMessageIntent` in `Info.plist`, I found it from a GitHub page...

#### WebSocket
The `URLSessionWebSocketTask` provided is not sufficient for my needs. It does not expose the status code when an error occurs. For example, I would like to handle the error after receiving the 401 unauthorized status code. Therefore, I gave up the `URLSessionWebSocketTask`, choosing the `NIOWebSocket` framework to implement my own webSocket client. Although I was not familiar with it, I could find a lot of sample code from google/AI. Cracking it is still possible.

#### Centralise UI Flow
In this app, all UIs are built by SwiftUI, and I would like to have something like the navigation coordinator pattern in UIKit. Therefore, I implement the `Flow` component to handle all SwiftUI views' instantiation and communication between views. The single view component doesn't have to know which is its next view. Also the navigation, because of the `NavigationStack`, controlling it outside of the view is possible, easier to change the UI flow and cleaner code.

#### Swift 6
The compiler will complain if something is not thread-safe, non-sendable. In order to satisfy it, conform to `Sendable`, the followings are the approaches I mostly use:
1. actor
2. @MainActor final class
3. immutable struct
4. @Sendable closure
5. enum

### Technologies
1. Swift 6
2. WebSocket
3. Async/await
4. SwiftUI
5. AsyncStream
6. APNs
7. Core Data
8. Vapor for back-end

### Goals to achieve
1. Learn webSocket
2. Deal with Swift 6
3. Centralise UI flow in one component
4. MVVM, separate UI logic from business logic
5. Build a simple server by Swift Vapor for demonstration
6. Use decorator pattern for refresh token logic and caching

### Update History
* Version 1.0 basic chatting
* Version 1.1 push notification
* Version 1.2 messages caching
* Version 1.3 contacts caching
* Version 1.4 new UI design
* Version 1.5 unify web socket binary types
* Version 1.6 edit/delete message
* Version 1.7 search contacts and UI improvement
