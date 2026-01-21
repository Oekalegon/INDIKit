import Testing
@testable import INDIKit

@Suite
struct INDIKitTests {
    @Test("hello returns the expected greeting")
    func testHello() {
        let sut = INDIKit()
        #expect(sut.hello() == "Hello from INDIKit")
    }
}
