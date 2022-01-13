import XCTest

@testable import Inject

class ServiceFactoryTests: XCTestCase {
    func testSingletonFactoryDoesNotInvokeBuilderEarly() {
        let builderIsInvoked = BoolWrapper()
        let target = SingletonFactory {
            XCTAssertFalse(builderIsInvoked.value, "Builder is invoked more than once")
            builderIsInvoked.value = true
            return builderIsInvoked
        }

        XCTAssertFalse(builderIsInvoked.value, "Builder is invoked before `create` is called")
        _ = target.create()
        XCTAssert(builderIsInvoked.value, "Builder invocation was not tracked")
    }

    func testSingletonFactoryReturnsTheSameValueOnSubsequentCall() {
        let target = SingletonFactory(BoolWrapper.init)
        let firstValue = target.create() as AnyObject
        let secondValue = target.create() as AnyObject
        XCTAssert(firstValue === secondValue)
    }

    func testSingleUseFactoryDoesNotInvokeBuilderEarly() {
        let builderIsInvoked = BoolWrapper()
        let target = SingleUseFactory {
            XCTAssertFalse(builderIsInvoked.value, "Builder is invoked more than once")
            builderIsInvoked.value = true
            return builderIsInvoked
        }

        XCTAssertFalse(builderIsInvoked.value, "Builder is invoked before `create` is called")
        _ = target.create()
        XCTAssert(builderIsInvoked.value, "Builder invocation was not tracked")
    }

    func testSingleUseFactoryReturnsDifferentValueOnSubsequentCall() {
        let target = SingleUseFactory(BoolWrapper.init)
        let firstValue = target.create() as AnyObject
        let secondValue = target.create() as AnyObject
        XCTAssert(firstValue !== secondValue)
    }
}

private class BoolWrapper {
    var value = false
}
