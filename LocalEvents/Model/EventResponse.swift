import Foundation

struct EventsResponse: Decodable {
    let resultset: [ResultSet]
}

struct ResultSet: Decodable {
    let eventitem: [LocalEvent]
}

//Represents each item inside the "resultset" array.
//This means each "resultset" object contains an array called "eventitem".
//Each element of "eventitem" is decoded as a LocalEvent
