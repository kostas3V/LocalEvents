import UIKit
import Kingfisher

//Allows to create a color using a hex color string
// MARK: - Hex Color Extension
extension UIColor {
    /// "#RRGGBB" or "RRGGBB" → UIColor
    convenience init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        str = str.replacingOccurrences(of: "#", with: "")

        guard str.count == 6, let int = UInt64(str, radix: 16) else { return nil }

        self.init(
            red:   CGFloat((int >> 16) & 0xFF) / 255,
            green: CGFloat((int >> 8 ) & 0xFF) / 255,
            blue:  CGFloat( int        & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Event Cell
final class EventCell: UITableViewCell {
    
    static let reuseID = "EventCell"
    
    // MARK: - SPINNER
    private let spinner: UIActivityIndicatorView = { //Private -> accessible only inside this class
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    // MARK: Shadow Container
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#EEEEEE")
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false //Enables Auto Layout constraints
        return view
    }()
    
    // MARK: Image
    private let eventImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill  //Scales the image to fill the image view
        view.clipsToBounds = true  //Ensures the image does not overflow outside the view’s bounds
        view.layer.cornerRadius = 8
        view.backgroundColor = .systemGray5 //Acts as a placeholder background. Visible while the image is loading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Title
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-bold", size: 16)
        label.numberOfLines = 2
        label.textColor = UIColor(hex: "#393E46")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Description
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Medium", size: 14)
        label.numberOfLines = 3
        label.textColor = UIColor(hex: "#393E46")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {//Creates the visual structure of the table
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(eventImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(descriptionLabel)
        eventImageView.addSubview(spinner)
        
        
        NSLayoutConstraint.activate([
            // Card
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12), //Left side
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),//Right side
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8), //Top side
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8), //Bottom side
            
            // Image
            eventImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            eventImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            eventImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            eventImageView.widthAnchor.constraint(equalToConstant: 80),
            eventImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            nameLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.topAnchor.constraint(equalTo: eventImageView.topAnchor),
            
            // Description
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),
            
            //Spinner
            spinner.centerXAnchor.constraint(equalTo: eventImageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: eventImageView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { //Cells created programmatically, not from a storyboard. By calling fatalError,
        fatalError("init(coder:) has not been implemented") //we explicitly say: This cell must NOT be initialized from    Interface Builder
    }
    
    // MARK: Shadow Performance
    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,       //Defines the exact shape of the shadow
            cornerRadius: cardView.layer.cornerRadius  //Matches the rounded corners of cardView
        ).cgPath
    }
    
    // MARK: Reuse
    //This method is called automatically by UIKit right before the cell is reused for a different row.
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.kf.cancelDownloadTask()  //Cancels any ongoing image download
        eventImageView.image = UIImage(systemName: "photo") //Sets a placeholder image to avoid showing the previous image.
        nameLabel.text = nil  //Clears old text so the new content starts clean
        descriptionLabel.text = nil //Clears old text so the new content starts clean
    }
    
    private func startLoading() {
        spinner.startAnimating()
        
        eventImageView.image = nil
        eventImageView.backgroundColor = .systemGray5
        
        nameLabel.alpha = 0.6
        descriptionLabel.alpha = 0.6
    }
    private func stopLoading() { //Restores the cell to its final, loaded state once the image finishes loading.
        spinner.stopAnimating()
        
        eventImageView.backgroundColor = .clear
        
        UIView.animate(withDuration: 0.2) {
            self.nameLabel.alpha = 1         //opacity
            self.descriptionLabel.alpha = 1
        }
    }
    
    
    // MARK: Configure
    func configure(with event: LocalEvent, index: Int) {
        nameLabel.text = event.title ?? "No title"
        // API does not provide description
            descriptionLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
         startLoading()

        // Placeholder while loading
        eventImageView.image = UIImage(systemName: "photo")

        // If id or imagetype is missing, stop spinner and return
        guard let id = event.id, let imagetype = event.imagetype else {//Checks if the event has a valid id and imagetype
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.eventImageView.image = UIImage(systemName: "photo")
            }
            return
        }
       
        // Use a unique image URL per cell (picsum.photos for testing)
        // let urlString = "https://dev.loqiva.com/images/events/\(id)_\(imagetype).jpg"
        let urlString = "https://picsum.photos/200?random=\(index)"

        if let url = URL(string: urlString) {
            // Cancel any previous download for reused cells
            eventImageView.kf.cancelDownloadTask()
            //Uses Kingfisher to load the image asynchronously
            eventImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                guard let self = self else { return } //Makes sure self (the cell) still exists

                switch result {
                case .success:
                    break // image automatically set by Kingfisher

                case .failure(let error):
                    print("Kingfisher error:", error)
                    self.eventImageView.image = UIImage(systemName: "photo")
                }

                self.stopLoading() //Stops the spinner and restores the labels’ alpha to full
            }
        } else { //If the URL is invalid, just stops the spinner without attempting to download an image.
            stopLoading()
        }
    }

}

