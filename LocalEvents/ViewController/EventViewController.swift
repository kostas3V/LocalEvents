import UIKit
// Fetches events from an API and display them with a UITableView
class EventsViewController: UIViewController {
    
    private let tableView = UITableView() //Display the list of Events
    private var events: [LocalEvent] = [] //Stores the events returned from the API
    
    //Shows a spinner while loading
    private let loadingSpinner: UIActivityIndicatorView = {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            return spinner
        }()
    //viewDidLoad() is used for the initial setup of the screen and is called once, when the ViewController is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Local Events"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupSpinner()
        loadEvents()
        setupStateLabels()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self    //Provides the number of rows
        tableView.dataSource = self  //Configures each cell

        tableView.register(EventCell.self,
                           forCellReuseIdentifier: EventCell.reuseID)  //Connects the custom cell class with the table view and ensures cells are reused efficiently while scrolling.
    }
    
    private func setupSpinner() {
            view.addSubview(loadingSpinner)  //Adds it to the main view of the view controller so it can be visible on the screen.
        //places the spinner in the middle of the screen.
            NSLayoutConstraint.activate([
                loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    private func loadEvents() {
        loadingSpinner.startAnimating()  //start the spinner
        emptyStateLabel.isHidden = true  //hide the emptyLabel
        errorStateLabel.isHidden = true  //hide the errorLabal
            Task {
                do {                                                    //Try to get events from the API and with await
                    events = try await EventService.shared.fetchEvents()//ensures that this line waits for the response
                        tableView.reloadData()                         //without blocking the main UI thread.
                    DispatchQueue.main.async {
                        self.loadingSpinner.stopAnimating()   //stop the spinner when the data is loaded
                        if self.events.isEmpty {                //check if the array is empty
                            self.emptyStateLabel.isHidden = false  //if yes show the message "No events found"
                        }
                    }
                } catch {                       //If the network request fails, print the error in the console.
                    print("API Error:", error)
                        DispatchQueue.main.async {
                        self.loadingSpinner.stopAnimating() //Stop the spinner
                        self.errorStateLabel.isHidden = false  //show the error label
                    }
                }
            }
        }
    
    private func setupEmptyState() {
        //This adds the emptyStateLabel to the view so it can be displayed on screen.
        view.addSubview(emptyStateLabel)
        //Places the label exactly in the center of the screen.
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No events found."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let errorStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Failed to load events. Please try again."
        label.textAlignment = .center
        label.textColor = .red
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupStateLabels() {
        //Adds the empty state label and error state label to the main view so they can be displayed when needed.
        view.addSubview(emptyStateLabel)
        view.addSubview(errorStateLabel)
        //Places empty state label and error state label in the center of the screen.
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func hideEmptyState() {  //Hides the label that says “No events found.”.
        emptyStateLabel.isHidden = true //This is used when you have events to display, so the empty state message should disappear.
        tableView.isHidden = false //Makes the table view visible again, so the list of events can be seen.
    }

}

extension EventsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        events.count
    }   //Tells the table view how many rows it should display in the given section.
        //Here, it returns the count of the events array, so each event has a row.
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Creating or reusing a cell for each row.

        let cell = tableView.dequeueReusableCell(   //Reuses cells instead of creating new ones every time with
            withIdentifier: EventCell.reuseID,         //EventCell.reuseID
            for: indexPath
        ) as! EventCell
        //he cell is configured with the corresponding event from the events
        cell.configure(with: events[indexPath.row], index: indexPath.row)
        return cell
    }
}
