/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

protocol PriceFetcher {
  func fetch(response: @escaping (PriceResponse?) -> Void)
}

struct BitcoinPriceFetcher: PriceFetcher {
  let networking: Networking
  
  // Initialize fetcher with networking object
  init(networking: Networking) {
    self.networking = networking
  }
  
  // fetch data, returning a PriceResponse object if successful
  func fetch(response: @escaping (PriceResponse?) -> Void) {
    networking.request(from: Coinbase.bitcoin, completion: { data, error in
      
      // Check for errors
      if let error = error {
        print("Error received requesting Bitcoin price: \(error.localizedDescription)")
      }
      
      // parse data into model object
      let decoded = self.decodeJSON(type: PriceResponse.self, from: data)
      if let decoded = decoded {
        print("Price returned: \(decoded.data.amount)")
      }
      response(decoded)
    })
  }
  
  // decode JSON into object of type 'T'
  private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
    let decoder = JSONDecoder()
    guard let from = from,
      let response = try? decoder.decode(type.self, from: from)
      else {
        return nil
    }
    return response
  }
}
