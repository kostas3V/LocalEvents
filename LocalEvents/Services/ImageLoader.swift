import UIKit

final class ImageLoader {
    static let shared = ImageLoader() //Creates one instance of ImageLoader.shared. So you can use ImageLoader.shared anywhere in your app.
    private let cache = NSCache<NSString, UIImage>() //An in-memory cache to store already downloaded images for faster reuse.
    //Takes a URL string of the image
    //and the completion handler returns the UIImage? asynchronously once the image is loaded.
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        //If the image was downloaded before, it’s immediately returned from the cache and avoids network request.
        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return
        }
        //If the URL string is invalid, it returns nil
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        //Uses URLSession to fetch image data and converts data into a UIImage. If download or conversion fails, returns nil.
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            //Stores the image in the cache so next time the same URL is requested, it doesn’t download again.
            self.cache.setObject(image, forKey: urlString as NSString)
            //UI updates must happen on the main thread, so we ensure the completion runs there.
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume() //Starts the network request.
    }
}

