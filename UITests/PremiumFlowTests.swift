import XCTest
import StoreKitTest

@MainActor
final class PremiumFlowTests: XCTestCase {
    private var app: XCUIApplication!
    private var purchases: SKTestSession!
    private let productID = "com.linapps.ykiflashcards.complete"

    override func setUp() async throws {
        continueAfterFailure = false
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "SisuCards", withExtension: "storekit"))
        purchases = try SKTestSession(contentsOf: url)
        purchases.resetToDefaultState(); purchases.clearTransactions(); purchases.disableDialogs = true
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-englishFirst", "YES", "-readPrompt", "NO", "-readAnswer", "NO", "-readSentence", "NO"]
        app.launchEnvironment["SISUCARDS_STOREKIT_TESTING"] = "1"
        app.launch()
        XCTAssertTrue(app.buttons["card.flip"].waitForExistence(timeout: 30))
    }

    private func openTab(_ name: String) {
        let target: XCUIElement
        switch name {
        case "Settings": target = app.staticTexts["settings.membership"]
        case "Progress": target = app.staticTexts["progress.known"]
        default: target = app.textFields["words.search"]
        }
        for _ in 0..<3 {
            let buttons = app.buttons.matching(NSPredicate(format: "label == %@", name))
            guard let button = buttons.allElementsBoundByIndex.first(where: { $0.isHittable }) else {
                XCTFail("No visible \(name) tab"); return
            }
            button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            if target.waitForExistence(timeout: 3) { return }
        }
        XCTFail("The \(name) screen did not open: \(app.debugDescription)")
    }

    private func openBook() {
        openTab("Words")
        let search = app.textFields["words.search"]
        search.tap()
        if let text = search.value as? String, text != "Search English or Finnish", !text.isEmpty {
            search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count))
        }
        search.typeText("book\n")
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "word.fi-")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["detail.finnish"].waitForExistence(timeout: 5))
    }

    func testFreeBWordKeepsTranslationAndRatingButLocksCompleteLesson() {
        openBook()
        XCTAssertTrue(app.buttons["lesson.locked"].exists)
        XCTAssertFalse(app.staticTexts["detail.sentence"].exists)
        XCTAssertFalse(app.otherElements["detail.artworkImage"].exists)
        capture("41-free-word-detail")
        app.buttons["lesson.locked"].tap()
        XCTAssertTrue(app.buttons["premium.buy"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["premium.restore"].isHittable)
        capture("42-premium-offer")
        app.buttons["premium.done"].tap()
        app.buttons["detail.status.known"].tap()
        app.buttons["detail.done"].tap()
        openTab("Progress")
        XCTAssertEqual(app.staticTexts["progress.known"].label, "1")
        openTab("Settings")
        XCTAssertEqual(app.staticTexts["settings.membership"].label, "3000 Finnish Words Free")
        capture("43-free-status-and-restore")
    }

    func testPurchaseUnlocksImmediatelySurvivesRelaunchAndRefundRelocks() async throws {
        openBook(); app.buttons["lesson.locked"].tap()
        XCTAssertTrue(app.buttons["premium.buy"].waitForExistence(timeout: 15))
        app.buttons["premium.buy"].tap()
        XCTAssertTrue(app.staticTexts["premium.unlocked"].waitForExistence(timeout: 15), app.debugDescription)
        capture("44-premium-purchase-success")
        app.buttons["premium.done"].tap()
        XCTAssertTrue(app.staticTexts["detail.sentence"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["lesson.locked"].exists)
        capture("45-unlocked-word-detail")
        app.terminate(); app.launch()
        XCTAssertTrue(app.buttons["card.flip"].waitForExistence(timeout: 30))
        openTab("Settings")
        XCTAssertTrue(app.staticTexts["settings.membership"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["settings.membership"].label, "3000 Finnish Words Premium")
        app.buttons["settings.restore"].tap()
        let restored = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: app.buttons["settings.restore"])
        XCTAssertEqual(XCTWaiter.wait(for: [restored], timeout: 10), .completed)
        XCTAssertEqual(app.staticTexts["settings.membership"].label, "3000 Finnish Words Premium")
        capture("premium-settings-and-restore")
        let transaction = try XCTUnwrap(purchases.allTransactions().first)
        try purchases.refundTransaction(identifier: transaction.identifier)
        let free = NSPredicate(format: "label == %@", "3000 Finnish Words Free")
        let revoked = expectation(for: free, evaluatedWith: app.staticTexts["settings.membership"])
        await fulfillment(of: [revoked], timeout: 10)
        openBook()
        XCTAssertTrue(app.buttons["lesson.locked"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["detail.sentence"].exists)
    }

    func testMixedAutoplayOffersFreeASetAndAPlaybackWorks() {
        app.buttons["study.autoplay"].tap()
        XCTAssertTrue(app.buttons["premium.buy"].waitForExistence(timeout: 15))
        let preview = app.buttons["premium.preview"]
        for _ in 0..<6 { if preview.isHittable { break }; app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(preview.isHittable)
        preview.tap()
        XCTAssertTrue(app.buttons["study.autoplay"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["session.count"].label, "0 / 211")
        app.buttons["study.autoplay"].tap()
        XCTAssertTrue(app.buttons["playback.next"].waitForExistence(timeout: 5))
        app.buttons["study.playbackSettings"].tap()
        app.buttons["playback.stop"].tap()
        app.buttons["card.reveal"].tap()
        XCTAssertTrue(app.staticTexts["card.sentence"].exists)
        XCTAssertFalse(app.buttons["lesson.locked"].exists)
        capture("46-free-A-complete-lesson")
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}

@MainActor
final class PersonalAccessFlowTests: XCTestCase {
    func testPersonalAccessWithoutStoreConfigurationSurvivesRelaunch() throws {
        #if DEBUG && SISUCARDS_PERSONAL
        continueAfterFailure = false
        let app = XCUIApplication()
        // No launch environment, no StoreKit file or transaction, no unlock preference.
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Progress"].waitForExistence(timeout: 30))
        app.tabBars.buttons["Progress"].tap()
        let knownBefore = app.staticTexts["progress.known"].label
        XCTAssertEqual(app.staticTexts["settings.membership"].label, "3000 Finnish Words Personal")
        XCTAssertFalse(app.buttons["settings.restore"].exists)
        app.buttons["Settings"].firstMatch.tap()
        app.buttons["settings.premium"].tap()
        XCTAssertTrue(app.staticTexts["premium.unlocked"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["premium.personalMode"].exists)
        XCTAssertFalse(app.buttons["premium.price"].exists)
        XCTAssertFalse(app.buttons["premium.buy"].exists)
        XCTAssertFalse(app.buttons["premium.restore"].exists)
        app.buttons["premium.done"].tap()
        app.terminate()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Progress"].waitForExistence(timeout: 30))
        app.tabBars.buttons["Progress"].tap()
        XCTAssertEqual(app.staticTexts["progress.known"].label, knownBefore)
        app.tabBars.buttons["Words"].tap()
        app.buttons["words.filters"].tap()
        app.buttons["filter.reset"].tap()
        app.buttons["filter.apply"].tap()
        app.textFields["words.search"].tap()
        app.textFields["words.search"].typeText("book\n")
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "word.fi-")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["detail.sentence"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["lesson.locked"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "personal-unlocked-book"; attachment.lifetime = .keepAlways; add(attachment)
        #else
        throw XCTSkip("Run with the Personal build configuration to verify personal UI.")
        #endif
    }
}
