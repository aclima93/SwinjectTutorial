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

@testable import Bitcoin_Adventurer

// Autoregister can handle PriceResponse and Price as long as there are no optionals in the initializer.

extension PriceResponse {
  init(data: Price) {
    self.init(data: data, warnings: nil)
  }
}

extension Price {
  init(amount: String) {
    self.init(base: .BTC, amount: amount, currency: .USD)
  }
}

let AMOUNT = "666"

class AutoregisterTests: XCTestCase {
  
  private let container = Container()
  
  // MARK: - Boilerplate methods
  
  override func setUp() {
    super.setUp()
    container.autoregister(Price.self, argument: String.self, initializer: Price.init(amount:))
    container.autoregister(PriceResponse.self, argument: Price.self, initializer: PriceResponse.init(data:))
  }
  
  override func tearDown() {
    super.tearDown()
    container.removeAll()
  }
  
  // MARK: - Tests
  
  func testPriceResponseData() {
    let price = container ~> (Price.self, argument: AMOUNT)
    let response = container ~> (PriceResponse.self, argument: price)
    XCTAssertEqual(response.data.amount, AMOUNT)
  }
  
  func testPrice() {
    let price = container ~> (Price.self, argument: AMOUNT)
    XCTAssertEqual(price.amount, AMOUNT)
  }

}
