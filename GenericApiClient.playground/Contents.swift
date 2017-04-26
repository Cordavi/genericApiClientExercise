//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let url = URL(string: "https://jsonplaceholder.typicode.com/photos")!

struct Photo {
  let id: UInt
  let title: String
}

extension Photo {
  init?(dictionary: [String: Any]) {
    guard let id = dictionary["id"] as? UInt,
      let title = dictionary["title"] as? String else {
        return nil
    }
    self.id = id
    self.title = title
  }
}

extension Photo {
  static let all = Resource<Any>(url: url, parseJSON: { json in
    guard let dictionaries = json as? [[String: Any]] else { return nil }
    return dictionaries.flatMap(Photo.init)
  })
}

struct Resource<T> {
  let url: URL
  let parse: (Data) -> T?
}

extension Resource {
  //Would build different inits for parsing different server data types
  init(url: URL, parseJSON: @escaping (Any) -> T?) {
    self.url = url
    self.parse = { data in
      let json = try? JSONSerialization.jsonObject(with: data, options: [])
      return json.flatMap(parseJSON)
    }
  }
}

struct ApiClient {
  func load<T>(resource: Resource<T>, completion: @escaping (T?) -> Void) {
    URLSession.shared.dataTask(with: resource.url) { data, _, _ in
      let result = data.flatMap(resource.parse)
      completion(result)
      }.resume()
  }
}

PlaygroundPage.current.needsIndefiniteExecution = true

ApiClient().load(resource: Photo.all) { result in
  print(result ?? "")
}
