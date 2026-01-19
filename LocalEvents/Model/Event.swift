import Foundation

struct LocalEvent: Decodable { //Defines a Swift struct that can be decoded from JSON
    let id: String?
    let title: String?
    let imagetype: String?

    enum CodingKeys: String, CodingKey { //Maps the JSON keys from the API to your struct properties.
        case id = "eventitemid"         //Here, eventitemid in JSON maps to id in your struct.
        case title                      //title and imagetype match the JSON keys, so no mapping change is needed.
        case imagetype
    }
}

