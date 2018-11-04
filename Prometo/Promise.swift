//
//  Promise.swift
//  Prometo
//
//  Created by younke on 28/10/2018.
//  Copyright © 2018 funjahmental. All rights reserved.
//

import Foundation

class Promise<T> {

    var value: T? {
        if case let .fulfilled(value) = state {
            return value
        }
        return nil
    }

    var error: Error? {
        if case let .failed(error) = state {
            return error
        }
        return nil
    }

    struct Callback {
        let onFullfil: ((T) -> Void)?
        let onError: ((Error) -> Void)?
    }

    enum State {
        case pending
        case fulfilled(T)
        case failed(Error)

        var isCompleted: Bool {
            if case .pending = self {
                return false
            }
            return true
        }
    }

    private var callbacks: [Callback] = []
    private var state: State {
        didSet {
            runCallbacks()
        }
    }

    init(value: T) {
        state = .fulfilled(value)
    }

    init() {
        state = .pending
    }

    func then(_ thenBlock: @escaping (T) -> Void) -> Promise<T> {
        appendCallback(onFullfil: thenBlock, onError: nil)
        return self
    }

    @discardableResult
    func `catch`(_ errorBlock: @escaping (Error) -> Void) -> Promise<T> {
        appendCallback(onFullfil: nil, onError: errorBlock)
        return self
    }

    func ensure(_ ensureBlock: @escaping () -> Void) {
        appendCallback(onFullfil: { _ in ensureBlock() }, onError: { _ in ensureBlock() })
    }

    func map<S>(_ transformBlock: @escaping (T) -> S) -> Promise<S> {
        let promise = Promise<S>()
        then { value in
            let transformedValue = transformBlock(value)
            promise.fulfill(transformedValue)
        }.catch { e in
            promise.fail(e)
        }
        return promise
    }

    func fulfill(_ value: T) {
        self.state = .fulfilled(value)
    }

    func fail(_ error: Error) {
        self.state = .failed(error)
    }

    private func appendCallback(onFullfil: ((T) -> Void)?, onError: ((Error) -> Void)?) {
        let callback = Callback(onFullfil: onFullfil, onError: onError)
        callbacks.append(callback)
        if state.isCompleted {
            dispatchCallback(callback: callback)
        }
    }

    private func runCallbacks() {
        guard state.isCompleted else { return }
        callbacks.forEach(dispatchCallback)
    }

    private func dispatchCallback(callback: Callback) {
        switch state {
        case .fulfilled(let value): callback.onFullfil?(value)
        case .failed(let error): callback.onError?(error)
        case .pending: return
        }
    }


}
