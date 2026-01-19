import Foundation

final class EventService {

    static let shared = EventService()  //Creates exactly one instance of EventService
    private init() {}                //Ensures no one else can create another instance

    func fetchEvents() async throws -> [LocalEvent] {  //Perform a network request without blocking the main thread.
                                                    //Indicates that this function can throw an error.
        let url = URL(string: "https://dev.loqiva.com/public/service/phonejson/eventlist")!
        var request = URLRequest(url: url)   //Creates a URLRequest
        request.httpMethod = "POST"             //Sets the HTTP method to POST.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //Sets the request header Content-Type to                                                   //application/json because the API expects JSON in the request body.
        
        let body: [String: Any] = [
            "rowsPerPage": 100,
            "page": 1,
            "latitude": 0.0,
            "longitude": 0.0,
            "categoryId": NSNull(),
            "search": ""
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body) //Converts the Swift dictionary into Data using                                                                    //JSONSerialization
        
        let (data, _) = try await URLSession.shared.data(for: request) //Performs the network request asynchronously.

        // Decode wrapper
        let decoded = try JSONDecoder().decode(EventsResponse.self, from: data) //Decodes the JSON response into a Swift model
                                                //Throws an error if JSON structure doesn't match your EventsResponse model.
        let allEvents = decoded.resultset.flatMap { $0.eventitem } //Returns a flat array of all events or throws an error if                                                         //something fails.
        return allEvents
    }
}
