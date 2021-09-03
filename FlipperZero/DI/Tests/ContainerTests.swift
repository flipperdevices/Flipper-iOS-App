import XCTest

@testable import Injector

class ContainerTests: XCTestCase {
    func testDefaultRegistrationResolvesDifferentValuesOnSubsequentCall() {
        let target = Container()
        target.register(TestImplementation.init)
        let firstValue = target.resolve(TestImplementation.self)
        let secondValue = target.resolve(TestImplementation.self)
        XCTAssert(firstValue !== secondValue)
    }

    func testInstanceRegistrationResolvesTheSameValue() {
        let target = Container()
        let registeredValue = TestImplementation()
        target.register(instance: registeredValue, as: TestService.self)
        let resolvedValue = target.resolve(TestService.self)
        XCTAssert(registeredValue === resolvedValue)
    }

    func testInstanceRegistrationAsSelfTypeResolvesTheSameValue() {
        let target = Container()
        let registeredValue = TestImplementation()
        target.register(instance: registeredValue)
        let resolvedValue = target.resolve(TestImplementation.self)
        XCTAssert(registeredValue === resolvedValue)
    }

    func testRegistrationAsSingletonResolvesTheSameValueOnSubsequentCall() {
        let target = Container()
        target.register(TestImplementation.init, as: TestService.self, isSingleton: true)
        let firstValue = target.resolve(TestService.self)
        let secondValue = target.resolve(TestService.self)
        XCTAssert(firstValue === secondValue)
    }

    func testSameTypeCouldBeRegisteredTwice() {
        let target = Container()
        target.register(TestImplementation.init, as: TestService.self, isSingleton: true)
        target.register(TestImplementation.init, isSingleton: true)
        let firstValue = target.resolve(TestService.self)
        let secondValue: TestService = target.resolve(TestImplementation.self)
        XCTAssert(firstValue !== secondValue)
    }
}

private protocol TestService: AnyObject {
}

private class TestImplementation: TestService {
}
