import Testing
@testable import Hearth

@Suite struct LaunchOptionsTests {
    @Test func parsesScreenArg() {
        #expect(LaunchOptions.parse(["Hearth", "--screen", "skill"]).screen == "skill")
    }

    @Test func noScreenByDefault() {
        #expect(LaunchOptions.parse(["Hearth"]).screen == nil)
    }

    @Test func screenWithoutValueIsIgnored() {
        #expect(LaunchOptions.parse(["Hearth", "--screen"]).screen == nil)
    }

    @Test func screenListCoversAllScreens() {
        let ids = Set(GalleryView.screenList.map(\.id))
        #expect(ids.contains("menubar") && ids.contains("settings"))
        #expect(GalleryView.screenList.count >= 12)
    }
}
