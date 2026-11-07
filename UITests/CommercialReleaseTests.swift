import XCTest

@MainActor
final class CommercialReleaseTests: XCTestCase {
    func testCommercialScreensHelpAndStoreOffer() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-englishFirst", "YES", "-readPrompt", "NO", "-readAnswer", "NO", "-readSentence", "NO"]
        // Use the real StoreKit product lookup, without a local purchase fixture.
        app.launch()
        XCTAssertTrue(app.buttons["review.known"].waitForExistence(timeout: 30))
        capture(app, "commercial-study")
        app.buttons["Words"].firstMatch.tap()
        XCTAssertTrue(app.textFields["words.search"].waitForExistence(timeout: 5))
        capture(app, "commercial-library")
        app.textFields["words.search"].tap()
        app.textFields["words.search"].typeText("apple")
        app.textFields["words.search"].typeText("\n")
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "word.fi-")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["detail.sentence"].waitForExistence(timeout: 5))
        let illustration = app.buttons["detail.image"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: illustration)
        waitForExpectations(timeout: 15)
        capture(app, "commercial-free-complete-lesson")
        app.buttons["detail.done"].tap()
        app.buttons["Progress"].firstMatch.tap()
        XCTAssertTrue(app.buttons["progress.support"].waitForExistence(timeout: 5))
        capture(app, "commercial-progress")
        app.buttons["progress.offlineStudy"].tap()
        XCTAssertTrue(app.buttons["offline.download"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["offline.wifiOnly"].exists)
        capture(app, "commercial-offline-study")
        app.buttons["Done"].tap()
        app.buttons["progress.support"].tap()
        XCTAssertTrue(app.buttons["support.done"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["support.privacy"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["support.website"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["support.email"].exists)
        capture(app, "commercial-help-and-privacy")
        app.buttons["support.done"].tap()
        app.buttons["progress.premium"].tap()
        let buy = app.buttons["premium.buy"]
        let loaded = buy.waitForExistence(timeout: 30)
        capture(app, "commercial-premium-offer")
        let result = XCTAttachment(string: loaded ? "Live StoreKit offer: \(buy.label)" : "Live StoreKit price unavailable.\n\(app.debugDescription)")
        result.name = "live-store-offer-result"; result.lifetime = .keepAlways; add(result)
        // Store availability can lag product configuration. Record it separately
        // while enforcing that free study and Help work without a store response.
        XCTAssertTrue(app.buttons["premium.restore"].exists)
        XCTAssertFalse(app.staticTexts["premium.personalMode"].exists)
        app.buttons["premium.done"].tap()
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let result = XCTAttachment(screenshot: app.screenshot())
        result.name = name; result.lifetime = .keepAlways; add(result)
    }
}

@MainActor
final class VocabularyTopicFlowTests: XCTestCase {
    func testMobileTopicBrowserSearchFiltersAndPractice() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-readPrompt", "NO", "-readAnswer", "NO", "-readSentence", "NO"]
        app.launch()
        XCTAssertTrue(app.buttons["review.known"].waitForExistence(timeout: 30))
        openWords(app)
        let home = app.buttons["topic.home"]
        XCTAssertTrue(home.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(home.isHittable)
        XCTAssertGreaterThanOrEqual(home.frame.minX, 0)
        XCTAssertLessThanOrEqual(home.frame.maxX, app.frame.maxX)
        capture(app, "topics-mobile-library")
        home.tap()
        XCTAssertTrue(app.staticTexts["Koti ja asuminen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["words.practice"].exists)
        capture(app, "topics-home-vocabulary")
        app.textFields["words.search"].tap()
        app.textFields["words.search"].typeText("house\n")
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "word.fi-")).firstMatch.waitForExistence(timeout: 5))
        app.buttons["words.practice"].tap()
        XCTAssertTrue(app.buttons["review.known"].waitForExistence(timeout: 5))
        openWords(app)
        app.buttons["words.backToTopics"].tap()
        XCTAssertTrue(home.waitForExistence(timeout: 5), app.debugDescription)
        app.buttons["words.filters"].tap()
        XCTAssertTrue(app.buttons["filter.apply"].waitForExistence(timeout: 5))
        app.buttons["filter.scope.known"].tap()
        app.buttons["filter.apply"].tap()
        XCTAssertTrue(app.staticTexts["No matching words"].waitForExistence(timeout: 5))
        app.buttons["Clear filters"].tap()
        XCTAssertTrue(app.buttons["words.practice"].waitForExistence(timeout: 5))
        app.buttons["words.backToTopics"].tap()
        app.segmentedControls["words.collections"].buttons["Word groups"].tap()
        let verbs = app.buttons["topic.commonVerbs"]
        XCTAssertTrue(verbs.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(verbs.isHittable)
        capture(app, "topics-core-word-groups")
        verbs.tap()
        XCTAssertTrue(app.staticTexts["Arjen verbit"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["words.filteredCount"].label, "247 shown")
        app.textFields["words.search"].tap()
        app.textFields["words.search"].typeText("eat\n")
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "word.fi-")).firstMatch.waitForExistence(timeout: 5))
        capture(app, "topics-common-verbs-search")
        app.buttons["words.practice"].tap()
        XCTAssertTrue(app.buttons["review.known"].waitForExistence(timeout: 5))
    }

    private func openWords(_ app: XCUIApplication) {
        let tabs = app.tabBars.buttons.matching(NSPredicate(format: "label == %@", "Words"))
        let search = app.textFields["words.search"]
        for _ in 0..<3 {
            if search.exists && search.isHittable { break }
            guard let tab = tabs.allElementsBoundByIndex.first(where: { $0.isHittable }) else {
                XCTFail("No visible Words tab: \(app.debugDescription)")
                return
            }
            tab.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            let visible = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: search)
            _ = XCTWaiter.wait(for: [visible], timeout: 3)
        }
        XCTAssertTrue(search.exists && search.isHittable, app.debugDescription)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
