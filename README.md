# Local Events iOS App

## How to run the project

1. Open the project by double-clicking `LocalEvents.xcodeproj`
2. Make sure you are using Xcode Version 26.2
3. Select an iPhone Simulator (iPhone 17)

## Assumptions
- URL: https://dev.loqiva.com/public/service/phonejson/eventslist is incorrect. The proper URL is:
https://dev.loqiva.com/public/service/phonejson/eventlist .
- The backend API does not provide event descriptions, so a short Lorem Ipsum text is used as a placeholder.
- Since the API does not provide images, placeholder images are loaded asynchronously using Kingfisher for caching and smooth scrolling.

## Architecture / Approach
- MVVM-style separation
    Model
        LocalEvent and EventsResponse structs represent the event data returned by the API.
    View
        EventsViewController displays a list of events.
        EventCell is responsible for the visual layout, showing the event title, description and image.
    ViewModel
        EventService acts as the middle layer between Model and View by fetching data asynchronously from the API using async/await.
- Built using UIKit and UITableView.
- Networking via async/await. The app fetches events asynchronously using Swift’s async/await pattern, keeping the UI responsive while the network request is in progress
- Image loading via Kingfisher.Event images are loaded asynchronously with Kingfisher, which provides caching, placeholder support, and smooth fade-in transitions.
- Custom UITableViewCell with reuse handling.Each event is displayed in a custom EventCell that manages its own layout, spinner, and image loading.
