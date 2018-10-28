//
//  PrometoTests.swift
//  PrometoTests
//
//  Created by younke on 28/10/2018.
//  Copyright © 2018 funjahmental. All rights reserved.
//

import XCTest
@testable import Prometo

class PrometoTests: XCTestCase {

    func testInitializeWithAValue() {
        let promise = Promise(value: 5)
        XCTAssertNotNil(promise.value)
        if let value = promise.value {
            XCTAssertEqual(value, 5)
        }
    }

    func testFullfillPromise() {
        let promise = Promise<String>()
        XCTAssertNil(promise.value)

        promise.fulfill("ok")
        XCTAssertNotNil(promise.value)
        if let value = promise.value {
            XCTAssertEqual(value, "ok")
        } else {

        }
    }

    func testFullfillCallsThenBlock() {
        let promise = Promise<String>()

        let exp = expectation(description: "did not call then block")
        let _ = promise.then { value in
            exp.fulfill()
            XCTAssertEqual(value, "ok")
        }
        promise.fulfill("ok")
        wait(for: [exp], timeout: 1.0)
    }

    func testFailCallsCatchBlock() {
        let promise = Promise<String>()
        let exp = expectation(description: "did not call catch block")
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        promise.then { _ in
            XCTFail()
        }.catch { error in
            exp.fulfill()
            let e = error as NSError
            XCTAssertEqual(e.domain, "test")
            XCTAssertEqual(e.code, 1)
        }
        promise.fail(testError)
        wait(for: [exp], timeout: 1.0)
    }

    func testFailsSetsError() {
        let promise = Promise<String>()
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        promise.fail(testError)
        XCTAssertNotNil(promise.error)
        if let err = promise.error as NSError? {
            XCTAssertEqual(err, testError)
        } else {
            XCTFail()
        }
    }

    func testMapTransformsFutureValue() {
        let promise = Promise<Int>()

        let exp = expectation(description: "did not call map block")
        let _ = promise.map { value in
            return String(value)
        }.then { value in
            exp.fulfill()
            XCTAssertEqual(value, "5")
        }.catch { e in
            XCTFail()
        }
        promise.fulfill(5)
        wait(for: [exp], timeout: 1.0)
    }

    func testMapCarriesOverErrors() {
        let promise = Promise<Int>()
        let exp = expectation(description: "did not call catch block")
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        let _ = promise.map { value in
            return String(value)
        }.then { value in
            XCTFail()
        }.catch { e in
            exp.fulfill()
            let e = e as NSError
            XCTAssertEqual(e.domain, "test")
            XCTAssertEqual(e.code, 1)
        }
        promise.fail(testError)
        wait(for: [exp], timeout: 1.0)
    }

}
