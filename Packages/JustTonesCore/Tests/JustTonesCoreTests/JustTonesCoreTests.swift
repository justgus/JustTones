import Testing
@testable import JustTonesCore

struct JustTonesCoreTests {
    @Test func versionIsPositive() {
        #expect(JustTonesCoreVersion.current > 0)
    }
}
