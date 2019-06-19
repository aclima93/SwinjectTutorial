/// Copyright (c) 2018 Razeware LLC
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

import XCTest
import Swinject
import SwinjectAutoregistration
import Foundation

@testable import Bitcoin_Adventurer

enum DataSet: String {
    case one
    case two

    static let all: [DataSet] = [.one, .two]
}

extension DataSet {
    var name: String { return rawValue }
    var filename: String { return "dataset-\(rawValue)" }
}

// for testing purposes, this implementations returns a response from disk instead of using an HTTP request
struct SimulatedNetworking: Networking {
  let filename: String
  
  func request(from: Endpoint, completion: @escaping CompletionHandler) {
    let data = readJSON(name: filename)
    completion(data, nil)
  }
  
  private func readJSON(name: String) -> Data? {
    let bundle = Bundle(for: SimulatedNetworkTests.self)
    guard let url = bundle.url(forResource: name, withExtension: "json") else { return nil }
    
    do {
      return try Data(contentsOf: url, options: .mappedIfSafe)
    } catch {
      XCTFail("Error occurred parsing test data")
      return nil
    }
  }
}

class SimulatedNetworkTests: XCTestCase {
  
  private let container = Container()
  
  // MARK: - Boilerplate methods
  
  override func setUp() {
    super.setUp()
    container.autoregister(Networking.self, argument: String.self, initializer: SimulatedNetworking.init)
    
    DataSet.all.forEach { dataset in
      container.register(BitcoinPriceFetcher.self, name: dataset.name) { resolver in
        let networking = resolver ~> (Networking.self, argument: dataset.filename)
        return BitcoinPriceFetcher(networking: networking)
      }
    }
  }
  
  override func tearDown() {
    super.tearDown()
    container.removeAll()
  }
  
  // MARK: - Tests
  
  func testDatasetOne() {
    let fetcher = container ~> (BitcoinPriceFetcher.self, name: DataSet.one.name)
    let expectation = XCTestExpectation(description: "Fetch Bitcoin price from dataset one")
    
    fetcher.fetch { response in
      XCTAssertEqual("100000.01", response!.data.amount)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testDatasetTwo() {
    XCTFail("Test not yet written.")
  }
}
