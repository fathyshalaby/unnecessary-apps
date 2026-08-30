import XCTest

final class App03DoNotTextThemUITests: XCTestCase {
    @MainActor
    @discardableResult
    private func focusTextField(_ field: XCUIElement, in app: XCUIApplication) -> Bool {
        for _ in 0..<8 {
            if field.isHittable {
                field.tap()
                if app.keyboards.firstMatch.waitForExistence(timeout: 1) {
                    return true
                }
            } else {
                app.swipeDown()
            }
        }
        return app.keyboards.firstMatch.exists
    }

    @MainActor
    func testDraftInterventionDeleteAndPersistence() throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()

        let editor = app.textViews["draftEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Draft editor should be visible on launch")
        editor.tap()
        editor.typeText("I should absolutely not send this message.")

        let start = app.buttons["startInterventionButton"]
        XCTAssertTrue(start.waitForExistence(timeout: 3), "Intervention button should be visible")
        XCTAssertTrue(start.isEnabled, "Intervention should enable after entering a draft")
        start.tap()

        let completed = app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS %@", "Intervention complete"))
            .firstMatch
        XCTAssertTrue(completed.waitForExistence(timeout: 15), "The 10-second intervention should complete")

        let delete = app.buttons["deleteEvidenceButton"]
        XCTAssertTrue(delete.waitForExistence(timeout: 3), "Delete evidence should remain available")
        XCTAssertTrue(delete.isEnabled, "Delete evidence should be enabled while a draft exists")
        delete.tap()

        let escaped = app.descendants(matching: .any)
            .matching(NSPredicate(format: "value CONTAINS %@", "A narrow escape"))
            .firstMatch
        XCTAssertTrue(escaped.waitForExistence(timeout: 3), "Deleting evidence should update the result")

        app.terminate()
        app.launchArguments = []
        app.launch()

        let stats = app.otherElements["rescueStats"]
        XCTAssertTrue(stats.waitForExistence(timeout: 8), "Stats should be visible after relaunch")
        XCTAssertTrue(stats.label.contains("1 completed cool-offs"), "Completed intervention should persist")
        XCTAssertTrue(stats.label.contains("1 drafts deleted"), "Deleted draft count should persist")
        XCTAssertFalse(delete.isEnabled, "After relaunch there should be no draft evidence to delete")
    }

    @MainActor
    func testWhatWasIDoingRecordsAndPersists() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app10whatwasidoing")
        app.launch()

        let reset = app.buttons["resetEvidenceButton"]
        XCTAssertTrue(reset.waitForExistence(timeout: 8), "App10 should expose its reset control")
        if reset.isEnabled {
            reset.tap()
            app.buttons["Erase all incident history"].tap()
        }

        let forgot = app.buttons["forgotButton"]
        XCTAssertTrue(forgot.waitForExistence(timeout: 3), "App10 should expose the primary action")
        let note = app.textFields["memoryNoteField"]
        XCTAssertTrue(note.waitForExistence(timeout: 5), "App10 should accept an optional last-known mission")
        note.tap()
        note.typeText("Reply to the landlord")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        forgot.tap()
        note.tap()
        note.typeText("Buy oat milk")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        forgot.tap()

        let count = app.descendants(matching: .any).matching(identifier: "incidentCount").firstMatch
        XCTAssertTrue(count.waitForExistence(timeout: 3), "App10 should expose its incident count")
        XCTAssertEqual(count.value as? String, "2", "Recording lapses should increment the count")
        XCTAssertTrue(app.staticTexts["Reply to the landlord"].waitForExistence(timeout: 5), "The private log should show the first mission")
        XCTAssertTrue(app.staticTexts["Buy oat milk"].exists, "The private log should show the second mission")

        app.terminate()
        app.launch()
        let persistedCount = app.descendants(matching: .any).matching(identifier: "incidentCount").firstMatch
        XCTAssertTrue(persistedCount.waitForExistence(timeout: 8), "App10 should relaunch with its counter")
        XCTAssertEqual(persistedCount.value as? String, "2", "App10 should persist recorded lapses")
        XCTAssertTrue(app.staticTexts["Reply to the landlord"].waitForExistence(timeout: 5), "Mission context should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteIncidentButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "App10 should expose individual deletion")
        delete.tap()
        let oneIncident = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedCount
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [oneIncident], timeout: 3),
            .completed,
            "Individual deletion should update the count"
        )

        app.buttons["resetEvidenceButton"].tap()
        app.buttons["Erase all incident history"].tap()
        let emptyCount = app.descendants(matching: .any).matching(identifier: "incidentCount").firstMatch
        let noIncidents = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "0"),
            object: emptyCount
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [noIncidents], timeout: 3),
            .completed,
            "Confirmed erase-all should clear every incident"
        )
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["resetEvidenceButton"]
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [resetDisabled], timeout: 3),
            .completed,
            "An empty archive should disable evidence management"
        )
    }

    @MainActor
    func testMeetingBingoMarksAndPersists() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app17meetingbingo")
        app.launch()

        let erase = app.buttons["eraseBingoDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Meeting Bingo should expose complete local-data erasure")
        erase.tap()
        app.buttons["Confirm erase the board history"].tap()

        let newMeeting = app.buttons["newMeetingButton"]
        XCTAssertTrue(newMeeting.waitForExistence(timeout: 8), "Meeting Bingo should expose a new-game control")
        let first = app.buttons["bingoSquare_0"]
        let second = app.buttons["bingoSquare_1"]
        let third = app.buttons["bingoSquare_2"]
        XCTAssertTrue(first.waitForExistence(timeout: 5), "Meeting Bingo should render its board")
        first.tap()
        second.tap()
        third.tap()

        let result = app.descendants(matching: .any).matching(identifier: "meetingBingoResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "A winning line should expose the bingo result")
        XCTAssertTrue((result.value as? String)?.contains("BINGO") ?? false, "Marking the top row should produce a real bingo")
        let completed = app.descendants(matching: .any).matching(identifier: "completedBingoCount").firstMatch
        XCTAssertTrue(completed.waitForExistence(timeout: 5), "Meeting Bingo should expose completed-game statistics")
        XCTAssertEqual(completed.value as? String, "1", "The first bingo should complete exactly one game")

        first.tap()
        XCTAssertFalse((result.value as? String)?.contains("BINGO") ?? true, "Breaking the line should remove the active bingo")
        XCTAssertEqual(completed.value as? String, "1", "Breaking a line must not erase the completed-game statistic")
        first.tap()
        XCTAssertTrue((result.value as? String)?.contains("BINGO") ?? false, "Restoring the line should restore the active bingo")
        XCTAssertEqual(completed.value as? String, "1", "The same board must never be counted twice")

        app.terminate()
        app.launch()
        let persistedSquare = app.buttons["bingoSquare_0"]
        XCTAssertTrue(persistedSquare.waitForExistence(timeout: 8), "Meeting Bingo should relaunch with its board")
        XCTAssertEqual(persistedSquare.value as? String, "Marked", "The winning marks should persist")
        let persistedCompleted = app.descendants(matching: .any).matching(identifier: "completedBingoCount").firstMatch
        XCTAssertEqual(persistedCompleted.value as? String, "1", "The once-per-board win state should persist")

        app.buttons["newMeetingButton"].tap()
        XCTAssertEqual(app.buttons["bingoSquare_0"].value as? String, "Unmarked", "A new meeting should deal a fresh unmarked board")
        XCTAssertEqual(app.buttons["bingoSquare_4"].value as? String, "Free space, already marked", "Every board should keep the center free space")
        XCTAssertEqual(persistedCompleted.value as? String, "1", "Starting a new board should preserve lifetime statistics")

        app.buttons["eraseBingoDataButton"].tap()
        app.buttons["Confirm erase the board history"].tap()
        let zeroGames = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "0"),
            object: persistedCompleted
        )
        XCTAssertEqual(XCTWaiter.wait(for: [zeroGames], timeout: 3), .completed, "Confirmed erasure should reset all game statistics")
    }

    @MainActor
    func testTinyGratitudeArchivesAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app18tinygratitude")
        app.launch()

        let clear = app.buttons["clearArchiveButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 8), "Tiny Gratitude should expose archive management")
        if clear.isEnabled {
            clear.tap()
            app.buttons["Erase gratitude archive"].tap()
        }

        let editor = app.textFields["Gratitude entry"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Tiny Gratitude should expose its entry field")
        editor.tap()
        editor.typeText("A tiny, excellent coffee.")
        app.buttons["archiveButton"].tap()
        editor.tap()
        editor.typeText("A sunny window.")
        app.buttons["archiveButton"].tap()

        let summary = app.descendants(matching: .any).matching(identifier: "gratitudeSummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Tiny Gratitude should expose useful archive totals")
        let twoSaved = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2 today, 2 saved, 1 days"),
            object: summary
        )
        XCTAssertEqual(XCTWaiter.wait(for: [twoSaved], timeout: 3), .completed, "Two entries should update the summary")
        let coffee = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "A tiny, excellent coffee.")
        ).firstMatch
        let window = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "A sunny window.")
        ).firstMatch
        XCTAssertTrue(coffee.waitForExistence(timeout: 5), "The first tiny win should appear in history")
        XCTAssertTrue(window.exists, "The second tiny win should appear in history")

        app.terminate()
        app.launch()
        let persistedClear = app.buttons["clearArchiveButton"]
        XCTAssertTrue(persistedClear.waitForExistence(timeout: 8), "Tiny Gratitude should relaunch with its archive")
        XCTAssertTrue(persistedClear.isEnabled, "The archived entry should persist")
        let persistedSummary = app.descendants(matching: .any).matching(identifier: "gratitudeSummary").firstMatch
        XCTAssertTrue(persistedSummary.waitForExistence(timeout: 5), "The archive summary should survive relaunch")
        XCTAssertEqual(persistedSummary.value as? String, "2 today, 2 saved, 1 days", "Both entries should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteGratitudeButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Tiny Gratitude should expose individual deletion")
        delete.tap()
        let oneSaved = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1 today, 1 saved, 1 days"),
            object: persistedSummary
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneSaved], timeout: 3), .completed, "Individual deletion should update the archive")

        persistedClear.tap()
        app.buttons["Erase gratitude archive"].tap()
        let emptyArchive = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "0 today, 0 saved, 0 days"),
            object: persistedSummary
        )
        XCTAssertEqual(XCTWaiter.wait(for: [emptyArchive], timeout: 3), .completed, "Confirmed erasure should empty the archive")
        let archiveDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: persistedClear
        )
        XCTAssertEqual(XCTWaiter.wait(for: [archiveDisabled], timeout: 3), .completed, "An empty archive should disable management")
    }

    @MainActor
    func testRealEmailAnalyzesAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app20realemail")
        app.launch()

        let editor = app.textViews["Email evidence"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Real Email should expose its evidence editor")
        editor.tap()
        editor.typeText("Just actually circle back with the team. Please send the file today.")
        app.buttons["analyzeEmailButton"].tap()

        let metrics = app.descendants(matching: .any).matching(identifier: "emailMetrics").firstMatch
        XCTAssertTrue(metrics.waitForExistence(timeout: 5), "Analysis should produce the metrics card")
        app.swipeUp()
        app.swipeUp()
        let fogTerms = app.descendants(matching: .any).matching(identifier: "emailFogTerms").firstMatch
        XCTAssertTrue(fogTerms.waitForExistence(timeout: 5), "Analysis should disclose matched fog phrases")
        XCTAssertTrue((fogTerms.value as? String)?.contains("circle back") ?? false, "Phrase matching should report the actual corporate phrase")
        let firstScore = app.descendants(matching: .any).matching(identifier: "emailClarityScore").firstMatch
        XCTAssertEqual(firstScore.value as? String, "79 out of 100", "The published scoring rules should remain deterministic")

        let clear = app.buttons["clearEmailButton"]
        XCTAssertTrue(clear.isEnabled, "Email evidence should be clearable after analysis")
        clear.tap()
        XCTAssertFalse(clear.isEnabled, "Clearing should remove the local analysis evidence")
        XCTAssertFalse(app.descendants(matching: .any).matching(identifier: "emailMetrics").firstMatch.exists, "Clearing should remove stale metrics")

        app.swipeDown()
        app.swipeDown()
        editor.tap()
        editor.typeText("Please adjust the file by Friday.")
        app.buttons["analyzeEmailButton"].tap()
        app.swipeUp()
        app.swipeUp()
        let clearScore = app.descendants(matching: .any).matching(identifier: "emailClarityScore").firstMatch
        XCTAssertTrue(clearScore.waitForExistence(timeout: 5), "A fresh analysis should replace the cleared report")
        XCTAssertEqual(clearScore.value as? String, "100 out of 100", "Whole-token matching must not count 'just' inside 'adjust'")
        let clearFogTerms = app.descendants(matching: .any).matching(identifier: "emailFogTerms").firstMatch
        XCTAssertTrue((clearFogTerms.value as? String)?.contains("None") ?? false, "A clear sample should disclose that no listed phrase matched")

        app.terminate()
        app.launch()
        XCTAssertFalse(app.buttons["clearEmailButton"].isEnabled, "Email evidence and analysis must not persist across relaunch")
        XCTAssertFalse(app.descendants(matching: .any).matching(identifier: "emailMetrics").firstMatch.exists, "A relaunch should start without retained metrics")
    }

    @MainActor
    func testSnackRouletteSpinsAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app22snackroulette")
        app.launch()

        let clear = app.buttons["clearSnackHistoryButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 8), "Snack Roulette should expose complete local-data erasure")
        if clear.isEnabled {
            clear.tap()
            app.buttons["Confirm erase the pantry and spin history"].tap()
        }

        let editor = app.textFields["Comma-separated snacks"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Snack Roulette should expose its pantry field")
        editor.tap()
        editor.typeText("Toast, toast, Banana")
        let choices = app.descendants(matching: .any).matching(identifier: "snackChoiceCount").firstMatch
        XCTAssertTrue(choices.waitForExistence(timeout: 5), "Snack Roulette should expose its validated option count")
        XCTAssertEqual(choices.value as? String, "2", "Pantry validation should trim and case-insensitively deduplicate choices")

        let spin = app.buttons["spinSnackButton"]
        XCTAssertTrue(spin.isEnabled, "Two valid pantry choices should enable spinning")
        spin.tap()
        let result = app.descendants(matching: .any).matching(identifier: "snackResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "A spin should expose its ruling")
        let firstResult = result.value as? String ?? ""
        XCTAssertTrue(firstResult.contains("Toast") || firstResult.contains("Banana"), "The ruling should use a real pantry choice")

        spin.tap()
        let changedPick = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value != %@", firstResult),
            object: result
        )
        XCTAssertEqual(XCTWaiter.wait(for: [changedPick], timeout: 3), .completed, "Two-choice roulette must avoid an immediate repeat")
        let secondResult = result.value as? String ?? ""
        XCTAssertTrue(secondResult.contains("Toast") || secondResult.contains("Banana"), "The second ruling should still come from the pantry")

        let historyCount = app.descendants(matching: .any).matching(identifier: "snackHistoryCount").firstMatch
        XCTAssertTrue(historyCount.waitForExistence(timeout: 5), "Spins should create a local history")
        XCTAssertEqual(historyCount.value as? String, "2", "Two spins should create two records")

        app.terminate()
        app.launch()
        let persistedEditor = app.textFields["Comma-separated snacks"]
        XCTAssertTrue(persistedEditor.waitForExistence(timeout: 8), "The pantry should restore after relaunch")
        XCTAssertEqual(persistedEditor.value as? String, "Toast, toast, Banana", "The user-authored pantry should persist locally")
        let persistedCount = app.descendants(matching: .any).matching(identifier: "snackHistoryCount").firstMatch
        XCTAssertEqual(persistedCount.value as? String, "2", "The complete spin history should persist")

        let delete = app.buttons.matching(identifier: "deleteSnackPickButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual spin deletion should be available")
        delete.tap()
        let oneSpin = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneSpin], timeout: 3), .completed, "Deleting one spin should retain the other")

        app.buttons["clearSnackHistoryButton"].tap()
        app.buttons["Confirm erase the pantry and spin history"].tap()
        let noChoices = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "0"),
            object: app.descendants(matching: .any).matching(identifier: "snackChoiceCount").firstMatch
        )
        XCTAssertEqual(XCTWaiter.wait(for: [noChoices], timeout: 3), .completed, "Confirmed erasure should remove the pantry")
        XCTAssertFalse(app.buttons["spinSnackButton"].isEnabled, "An empty pantry must disable spinning")
        XCTAssertEqual(persistedCount.value as? String, "0", "Confirmed erasure should remove spin history")
    }

    @MainActor
    func testApologyGeneratorDraftsCopiesAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app30apologydraft")
        app.launchArguments.append("-UITestingForceFallback")
        app.launch()

        let editor = app.textFields["What did you do?"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Apology Generator should expose its crime field")
        editor.tap()
        editor.typeText("eating the last dumpling")
        app.buttons["generateApologyButton"].tap()

        let status = app.descendants(matching: .any).matching(identifier: "modelStatus").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5), "Apology Generator should disclose its model path")
        let completed = XCTNSPredicateExpectation(
            predicate: NSPredicate(
                format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                "Draft approved",
                "backup apology clerk"
            ),
            object: status
        )
        XCTAssertEqual(XCTWaiter.wait(for: [completed], timeout: 30), .completed, "Apology generation should finish on-device or use its local fallback")

        let draft = app.descendants(matching: .any).matching(identifier: "apologyDraft").firstMatch
        XCTAssertTrue(draft.waitForExistence(timeout: 5), "Apology Generator should expose the generated draft")
        XCTAssertFalse((draft.value as? String)?.contains("standing by") ?? true, "Generation should replace the initial placeholder")

        let copy = app.buttons["copyDraftButton"]
        XCTAssertTrue(copy.waitForExistence(timeout: 5), "A generated apology should expose copy")
        XCTAssertTrue(copy.isEnabled, "A generated apology should be copyable")
        copy.tap()
        XCTAssertTrue(app.buttons["clearApologyButton"].isEnabled, "The generated apology should be clearable")
        app.buttons["clearApologyButton"].tap()
        XCTAssertFalse(copy.isEnabled, "Clearing should remove the generated draft")
        let clearedDraft = app.descendants(matching: .any).matching(identifier: "apologyDraft").firstMatch
        XCTAssertTrue(clearedDraft.waitForExistence(timeout: 3), "Clearing should keep the empty result visible")
        let cleared = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS[c] %@", "standing by"),
            object: clearedDraft
        )
        XCTAssertEqual(XCTWaiter.wait(for: [cleared], timeout: 3), .completed, "Clearing should restore the private empty state")
    }

    @MainActor
    func testHydrationNarcLogsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app43hydrationnarc")
        app.launchArguments = ["-UITestingDayOverride", "2099-01-02"]
        app.launch()

        let progress = app.descendants(matching: .any).matching(identifier: "hydrationProgress").firstMatch
        XCTAssertTrue(progress.waitForExistence(timeout: 8), "Hydration Narc should expose progress")
        XCTAssertTrue(app.buttons["importHydrationHealthButton"].waitForExistence(timeout: 5), "Hydration Narc should expose its optional Apple Health water path")
        let reset = app.buttons["resetHydrationButton"]
        XCTAssertTrue(reset.waitForExistence(timeout: 5), "Hydration Narc should expose confirmed reset")
        if reset.isEnabled {
            reset.tap()
            app.buttons["Confirm empty today's ledger"].tap()
        }

        app.buttons["logGlassButton"].tap()
        app.buttons["logGlassButton"].tap()
        XCTAssertTrue((progress.value as? String)?.hasPrefix("2 of ") ?? false, "Logging should increment the daily serving count")
        app.buttons["undoGlassButton"].tap()
        XCTAssertTrue((progress.value as? String)?.hasPrefix("1 of ") ?? false, "Undo should repair an accidental serving")
        app.buttons["logGlassButton"].tap()

        app.terminate()
        app.launch()
        let persistedProgress = app.descendants(matching: .any).matching(identifier: "hydrationProgress").firstMatch
        XCTAssertTrue(persistedProgress.waitForExistence(timeout: 8), "The same-day ledger should restore after relaunch")
        XCTAssertTrue((persistedProgress.value as? String)?.hasPrefix("2 of ") ?? false, "The same-day serving count should persist")

        app.terminate()
        app.launchArguments = ["-UITestingDayOverride", "2099-01-03"]
        app.launch()
        let rolledProgress = app.descendants(matching: .any).matching(identifier: "hydrationProgress").firstMatch
        XCTAssertTrue(rolledProgress.waitForExistence(timeout: 8), "The next-day ledger should load")
        XCTAssertTrue((rolledProgress.value as? String)?.hasPrefix("0 of ") ?? false, "A new calendar day should start at zero")
        let yesterday = app.descendants(matching: .any).matching(identifier: "hydrationHistoryDay").firstMatch
        XCTAssertTrue(yesterday.waitForExistence(timeout: 5), "The completed day should enter the seven-day local ledger")
        XCTAssertTrue((yesterday.value as? String)?.contains("2099-01-02: 2 of") ?? false, "Day rollover should preserve the prior summary")

        app.buttons["logGlassButton"].tap()
        app.buttons["resetHydrationButton"].tap()
        app.buttons["Confirm empty today's ledger"].tap()
        let resetComplete = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value BEGINSWITH %@", "0 of "),
            object: rolledProgress
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetComplete], timeout: 3), .completed, "Confirmed reset should clear only today's count")
        XCTAssertTrue(yesterday.exists, "Resetting today should preserve earlier summaries")
    }

    @MainActor
    func testChairFinderInspectsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app01chairfinder")
        app.launch()

        let clear = app.buttons["clearChairCandidatesButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 8), "Chair Finder should expose local archive deletion")
        if clear.isEnabled {
            clear.tap()
            app.buttons["Erase all chair observations"].tap()
        }

        let name = app.textFields["chairNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Chair Finder should accept a real observed chair")
        name.tap()
        name.typeText("Window chair")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        app.buttons["addChairCandidateButton"].tap()
        XCTAssertTrue(app.staticTexts["Window chair"].waitForExistence(timeout: 5), "The observed chair should enter the private shortlist")

        name.tap()
        name.typeText("Kitchen throne")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        app.buttons["addChairCandidateButton"].tap()
        XCTAssertTrue(app.staticTexts["Kitchen throne"].waitForExistence(timeout: 5), "A second observed chair should enter the shortlist")

        let inspect = app.buttons["inspectChairButton"]
        XCTAssertTrue(inspect.waitForExistence(timeout: 5), "Chair Finder should expose ranking")
        XCTAssertTrue(inspect.isEnabled, "A real shortlist should enable ranking")
        inspect.tap()

        let verdict = app.descendants(matching: .any).matching(identifier: "chairVerdict").firstMatch
        XCTAssertTrue(verdict.waitForExistence(timeout: 5), "Chair Finder should expose its ranked verdict")
        let verdictText = verdict.value as? String ?? ""
        XCTAssertTrue(
            verdictText.contains("Window chair") || verdictText.contains("Kitchen throne"),
            "The verdict should name a user-created chair"
        )

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Window chair"].waitForExistence(timeout: 8), "Chair observations should survive relaunch")
        XCTAssertTrue(app.staticTexts["Kitchen throne"].exists, "The full shortlist should survive relaunch")

        let persistedVerdict = app.descendants(matching: .any).matching(identifier: "chairVerdict").firstMatch
        XCTAssertTrue(persistedVerdict.waitForExistence(timeout: 5), "The ranked verdict should remain accessible after relaunch")
        XCTAssertFalse(
            (persistedVerdict.value as? String)?.contains("refuses to invent furniture") ?? true,
            "The ranked verdict should survive relaunch"
        )

        app.buttons["clearChairCandidatesButton"].tap()
        app.buttons["Erase all chair observations"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyChairLedger").firstMatch.waitForExistence(timeout: 5), "Confirmed clear-all should erase the local archive")
        XCTAssertFalse(app.buttons["inspectChairButton"].isEnabled, "An empty archive should disable ranking")
    }

    @MainActor
    func testBathroomMapSavesPersistsAndClearsWithoutLocation() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app02bathroommap")
        app.launch()

        let manualPin = app.buttons["reportBathroomMapCenterButton"]
        XCTAssertTrue(manualPin.waitForExistence(timeout: 12), "Bathroom Map should expose a no-permission map fallback")
        manualPin.tap()

        let name = app.textFields["bathroomNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 8), "Bathroom Map should open its private field report")
        name.tap()
        name.typeText("Museum ground floor")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let save = app.buttons["saveBathroomReportButton"]
        if !save.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(save.waitForExistence(timeout: 5), "Bathroom Map should expose its local save action")
        save.tap()

        XCTAssertTrue(app.staticTexts["Museum ground floor"].waitForExistence(timeout: 8), "Saved report should appear in the private ledger")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Museum ground floor"].waitForExistence(timeout: 8), "Saved bathroom report should survive relaunch")

        let clear = app.buttons["clearBathroomReportsButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 5), "Bathroom Map should expose clear-all for local data")
        clear.tap()
        app.buttons["Clear all bathroom reports"].tap()
        XCTAssertTrue(app.staticTexts["No reports yet"].waitForExistence(timeout: 5), "Clear-all should restore the empty bathroom ledger")
    }

    @MainActor
    func testBathroomMapSearchReachesAUsefulOutcome() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app02bathroommap")
        app.launch()

        let search = app.buttons["findBathroomsButton"]
        XCTAssertTrue(search.waitForExistence(timeout: 12), "Bathroom Map should expose visible-region search")

        let status = app.descendants(matching: .any).matching(identifier: "bathroomMapStatus").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5), "Bathroom Map should expose search status")
        search.tap()

        let completed = XCTNSPredicateExpectation(
            predicate: NSPredicate(
                format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                "Found",
                "found no restroom",
                "search is taking a break"
            ),
            object: status
        )
        XCTAssertEqual(XCTWaiter.wait(for: [completed], timeout: 20), .completed, "Bathroom search should return results or a truthful manual fallback")
    }

    @MainActor
    func testSocialBatteryPrintsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app04socialbatteryreceipt")
        app.launch()

        let erase = app.buttons["eraseSocialBatteryDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Social Battery should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase every receipt"].tap()
        }

        let event = app.textFields["Event name (optional)"]
        XCTAssertTrue(event.waitForExistence(timeout: 5), "Social Battery should accept optional event context")
        event.tap()
        event.typeText("Dinner with friends")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let printReceipt = app.buttons["printReceiptButton"]
        XCTAssertTrue(printReceipt.waitForExistence(timeout: 8), "Social Battery should expose receipt generation")
        printReceipt.tap()

        let result = app.descendants(matching: .any).matching(identifier: "socialBatteryResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "The exact self-report receipt should be accessible")
        let drainReceipt = result.value as? String ?? ""
        XCTAssertTrue(drainReceipt.contains("Reported change: 8/10 → 3/10 (-5)"), "The receipt should preserve the signed before/after change")
        XCTAssertTrue(drainReceipt.contains("Observed drain: 5 points over 60 minutes"), "Duration should be real context rather than a decorative slider")

        let historyCount = app.descendants(matching: .any).matching(identifier: "socialBatteryHistoryCount").firstMatch
        XCTAssertTrue(historyCount.waitForExistence(timeout: 5), "A receipt should enter private history")
        XCTAssertEqual(historyCount.value as? String, "1", "The first receipt should file one record")

        let after = app.sliders["Energy after"]
        XCTAssertTrue(after.waitForExistence(timeout: 5), "The actual after-energy control should be accessible")
        for _ in 0..<4 where !after.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(after.isHittable, "The test should interact with the visible slider rather than a stale offscreen match")
        after.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(after.value as? String, "10", "The upper energy bound should be ten")
        for _ in 0..<4 where !printReceipt.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(printReceipt.isHittable, "The second receipt should use the visible primary action")
        printReceipt.tap()
        let rechargeReceipt = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "Recharge credit: +2 points"),
            object: result
        )
        XCTAssertEqual(XCTWaiter.wait(for: [rechargeReceipt], timeout: 3), .completed, "An increased self-report should be recorded as a credit, not forced into damage")

        let twoReceipts = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2"),
            object: historyCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [twoReceipts], timeout: 3), .completed, "Both observed outcomes should be filed")

        app.terminate()
        app.launch()
        let persistedEvent = app.textFields["Event name (optional)"]
        XCTAssertTrue(persistedEvent.waitForExistence(timeout: 8), "Current event context should restore after relaunch")
        XCTAssertEqual(persistedEvent.value as? String, "Dinner with friends", "The event label should persist locally")
        let persistedCount = app.descendants(matching: .any).matching(identifier: "socialBatteryHistoryCount").firstMatch
        XCTAssertEqual(persistedCount.value as? String, "2", "Receipt history should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteSocialReceiptButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual receipt deletion should be available")
        delete.tap()
        let oneReceipt = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneReceipt], timeout: 3), .completed, "Deleting one receipt should preserve the other")

        app.buttons["resetReceiptButton"].tap()
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["resetReceiptButton"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetDisabled], timeout: 3), .completed, "Void should clear only the current report")

        app.buttons["eraseSocialBatteryDataButton"].tap()
        app.buttons["Confirm erase every receipt"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptySocialBatteryHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove every receipt")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should zero receipt history")
    }

    @MainActor
    func testFridgeWitnessInterrogatesAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app05fridgewitness")
        app.launch()

        let erase = app.buttons["eraseFridgeDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Fridge Witness should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase the inventory"].tap()
        }

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyFridgeInventory").firstMatch.waitForExistence(timeout: 5), "First use should contain no seeded fictional evidence")
        let interrogate = app.buttons["interrogateFridgeButton"]
        XCTAssertTrue(interrogate.waitForExistence(timeout: 8), "Fridge Witness should expose interrogation")
        XCTAssertFalse(interrogate.isEnabled, "An empty inventory should not fabricate a witness statement")

        let name = app.textFields["Food or container name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Fridge Witness should accept real user-owned inventory")
        name.tap()
        name.typeText("Greek Yogurt")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let quantity = app.sliders["Quantity"]
        XCTAssertTrue(quantity.waitForExistence(timeout: 5), "The real quantity control should be accessible")
        XCTAssertEqual(quantity.value as? String, "1", "A new evidence draft should default to one unit")

        let file = app.buttons["fileFridgeEvidenceButton"]
        XCTAssertTrue(file.isEnabled, "A valid food name should enable filing")
        file.tap()

        let inventoryCount = app.descendants(matching: .any).matching(identifier: "fridgeInventoryCount").firstMatch
        XCTAssertTrue(inventoryCount.waitForExistence(timeout: 5), "The local inventory should expose its item-type count")
        XCTAssertEqual(inventoryCount.value as? String, "1", "The first real item should create one inventory row")
        let itemQuantity = app.descendants(matching: .any).matching(identifier: "fridgeItemQuantity").firstMatch
        XCTAssertEqual(itemQuantity.value as? String, "1", "The inventory should preserve the filed quantity")

        name.tap()
        name.typeText("greek yogurt")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        file.tap()
        XCTAssertEqual(inventoryCount.value as? String, "1", "A case-insensitive matching item and reminder should merge rather than duplicate")
        XCTAssertEqual(itemQuantity.value as? String, "2", "Merged evidence should add the reset one-unit quantity")

        interrogate.tap()
        let statement = app.descendants(matching: .any).matching(identifier: "fridgeWitnessStatement").firstMatch
        XCTAssertTrue(statement.waitForExistence(timeout: 5), "Inventory interrogation should expose a truthful statement")
        XCTAssertTrue((statement.value as? String)?.contains("1 item type, 2 total units") ?? false, "The statement should use actual inventory totals")
        XCTAssertTrue((statement.value as? String)?.contains("due within three days") ?? false, "The default tomorrow reminder should enter the attention window")
        XCTAssertTrue((statement.value as? String)?.contains("not a freshness or safety verdict") ?? false, "The statement should preserve the food-safety boundary")

        app.terminate()
        app.launch()
        let persistedCount = app.descendants(matching: .any).matching(identifier: "fridgeInventoryCount").firstMatch
        XCTAssertTrue(persistedCount.waitForExistence(timeout: 8), "The inventory should restore after relaunch")
        XCTAssertEqual(persistedCount.value as? String, "1", "The item type should persist locally")
        let persistedQuantity = app.descendants(matching: .any).matching(identifier: "fridgeItemQuantity").firstMatch
        XCTAssertEqual(persistedQuantity.value as? String, "2", "The merged quantity should persist locally")

        let useOne = app.buttons.matching(identifier: "useOneFridgeItemButton").firstMatch
        XCTAssertTrue(useOne.waitForExistence(timeout: 5), "Inventory should expose a real consumption action")
        useOne.tap()
        let oneUnit = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedQuantity
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneUnit], timeout: 3), .completed, "Use one should decrement rather than delete a multi-unit item")

        let remove = app.buttons.matching(identifier: "discardFridgeItemButton").firstMatch
        XCTAssertTrue(remove.waitForExistence(timeout: 5), "Inventory should expose row removal")
        remove.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyFridgeInventory").firstMatch.waitForExistence(timeout: 5), "Removing the final row should restore the truthful empty state")
        XCTAssertEqual(persistedCount.value as? String, "0", "Removing the final row should zero inventory count")

        let freshName = app.textFields["Food or container name"]
        freshName.tap()
        freshName.typeText("Spinach")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        app.buttons["fileFridgeEvidenceButton"].tap()
        app.buttons["eraseFridgeDataButton"].tap()
        app.buttons["Confirm erase the inventory"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyFridgeInventory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove the complete local inventory")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should leave zero item types")
    }

    @MainActor
    func testReceiptDamageReportsAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app06receiptemotionaldamage")
        app.launch()

        let erase = app.buttons["erasePurchaseDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Receipt Damage should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase the receipt ledger"].tap()
        }

        let purchase = app.textFields["Purchase name (optional)"]
        XCTAssertTrue(purchase.waitForExistence(timeout: 5), "Receipt Damage should accept optional purchase context")
        purchase.tap()
        purchase.typeText("Reusable Bottle")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let amount = app.textFields["Amount in EUR"]
        XCTAssertTrue(amount.waitForExistence(timeout: 8), "Receipt Damage should expose amount entry")
        amount.tap()
        amount.typeText("12,50")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let validation = app.descendants(matching: .any).matching(identifier: "receiptAmountValidation").firstMatch
        XCTAssertTrue(validation.waitForExistence(timeout: 5), "Amount parsing should be transparent")
        XCTAssertEqual(validation.value as? String, "Valid amount €12.50", "Decimal comma input should parse to exact cents")

        let reminder = app.switches["purchaseReminderToggle"]
        XCTAssertTrue(reminder.waitForExistence(timeout: 5), "A purchase can opt into one contextual review reminder")
        for _ in 0..<4 where !reminder.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(reminder.isHittable, "The reminder control should be visible before interaction")
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(reminder.value as? String, "1", "The user should explicitly opt into the purchase review")
        app.swipeUp()
        let reminderStatus = app.descendants(matching: .any).matching(identifier: "purchaseNotificationStatus").firstMatch
        XCTAssertTrue(reminderStatus.waitForExistence(timeout: 5), "Opting in should explain the notification permission state")
        XCTAssertTrue((reminderStatus.label + " " + (reminderStatus.value as? String ?? "")).contains("We’ll ask before turning this reminder on"), "Merely enabling the control should defer the system permission request until filing")
        for _ in 0..<5 where !reminder.isHittable {
            app.swipeDown()
        }
        let visibleReminder = app.switches["purchaseReminderToggle"]
        XCTAssertTrue(visibleReminder.isHittable, "The test should turn the optional reminder back off visibly")
        for _ in 0..<3 where (visibleReminder.value as? String) != "0" {
            visibleReminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
            let reminderOff = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "value == %@", "0"),
                object: visibleReminder
            )
            if XCTWaiter.wait(for: [reminderOff], timeout: 1) == .completed {
                break
            }
        }
        XCTAssertEqual(visibleReminder.value as? String, "0", "The base acceptance purchase should file without requesting notification permission")

        let report = app.buttons["issueReportButton"]
        XCTAssertTrue(report.isEnabled, "A valid amount should enable the report")
        report.tap()

        let result = app.descendants(matching: .any).matching(identifier: "receiptDamageResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "The exact emotional invoice should be accessible")
        let plannedResult = result.value as? String ?? ""
        XCTAssertTrue(plannedResult.contains("€12.50 ÷ 10 = €1.25 per intended use"), "The report should expose exact rounded cost-per-use arithmetic")
        XCTAssertTrue(plannedResult.contains("marked planned by you"), "The report should preserve user-supplied intent without inference")

        let historyCount = app.descendants(matching: .any).matching(identifier: "purchaseHistoryCount").firstMatch
        XCTAssertTrue(historyCount.waitForExistence(timeout: 5), "A purchase reflection should enter private history")
        XCTAssertEqual(historyCount.value as? String, "1", "The first report should file one record")

        let planned = app.switches["plannedPurchaseToggle"]
        XCTAssertTrue(planned.waitForExistence(timeout: 5), "Purchase intent should be an explicit user-owned control")
        for _ in 0..<4 where !planned.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(planned.isHittable, "The test should interact with the visible intent control")
        planned.tap()
        for _ in 0..<4 where !report.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(report.isHittable, "The second invoice should use the visible primary action")
        report.tap()
        let impulseResult = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "marked impulse by you"),
            object: result
        )
        XCTAssertEqual(XCTWaiter.wait(for: [impulseResult], timeout: 3), .completed, "Turning off planned should file an explicit impulse label")

        let twoPurchases = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2"),
            object: historyCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [twoPurchases], timeout: 3), .completed, "Both user-supplied intent paths should be filed")
        let summary = app.descendants(matching: .any).matching(identifier: "purchaseLedgerSummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "The ledger should expose a useful summary")
        XCTAssertEqual(summary.value as? String, "2 filed, €25.00 logged, 1 marked impulse", "The summary should use real ledger totals")

        app.terminate()
        app.launch()
        let persistedAmount = app.textFields["Amount in EUR"]
        XCTAssertTrue(persistedAmount.waitForExistence(timeout: 8), "Current purchase inputs should restore after relaunch")
        XCTAssertEqual(persistedAmount.value as? String, "12,50", "The original decimal-comma input should persist locally")
        let persistedCount = app.descendants(matching: .any).matching(identifier: "purchaseHistoryCount").firstMatch
        XCTAssertEqual(persistedCount.value as? String, "2", "Purchase history should survive relaunch")

        let delete = app.buttons.matching(identifier: "deletePurchaseRecordButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual purchase deletion should be available")
        delete.tap()
        let onePurchase = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [onePurchase], timeout: 3), .completed, "Deleting one purchase should preserve the other")

        app.buttons["clearReceiptButton"].tap()
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["clearReceiptButton"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetDisabled], timeout: 3), .completed, "Expunge should reset only the current receipt")

        app.buttons["erasePurchaseDataButton"].tap()
        app.buttons["Confirm erase the receipt ledger"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyPurchaseHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove every purchase reflection")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should zero purchase history")
    }

    @MainActor
    func testSockTribunalTracksAndResolvesCases() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app07socktribunal")
        app.launch()

        let erase = app.buttons["eraseSockArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Sock Tribunal should expose complete private-archive erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase complete sock archive"].tap()
        }

        let empty = app.descendants(matching: .any).matching(identifier: "emptySockDocket").firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "First use should contain no fictional sock cases")
        let caseCount = app.descendants(matching: .any).matching(identifier: "sockCaseCount").firstMatch
        XCTAssertEqual(caseCount.value as? String, "0", "The private docket should begin empty")

        let sock = app.textFields["Describe the unmatched sock"]
        XCTAssertTrue(sock.waitForExistence(timeout: 8), "Sock Tribunal should accept a real sock description")
        sock.tap()
        sock.typeText("one suspicious ankle sock")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let lastSeen = app.textFields["Last seen location (optional)"]
        XCTAssertTrue(lastSeen.waitForExistence(timeout: 5), "A case should accept useful last-seen context")
        lastSeen.tap()
        lastSeen.typeText("Laundry basket")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let reminder = app.switches["sockReminderToggle"]
        for _ in 0..<5 where !reminder.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(reminder.isHittable, "The contextual reminder control should be visible")
        reminder.tap()
        XCTAssertEqual(reminder.value as? String, "1", "The user should explicitly opt into the recheck")
        app.swipeUp()
        let notificationStatus = app.descendants(matching: .any).matching(identifier: "sockNotificationStatus").firstMatch
        XCTAssertTrue(notificationStatus.waitForExistence(timeout: 5), "Opting in should explain notification authorization timing")
        XCTAssertTrue((notificationStatus.label + " " + (notificationStatus.value as? String ?? "")).contains("We’ll ask before turning this reminder on"), "The system prompt should be deferred until a reminded case is filed")
        for _ in 0..<5 where !reminder.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(reminder.isHittable, "The test should turn the optional reminder back off visibly")
        reminder.tap()
        XCTAssertEqual(reminder.value as? String, "0", "The base acceptance case should file without requesting notification permission")

        let file = app.buttons["fileSockCaseButton"]
        for _ in 0..<5 where !file.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(file.isEnabled && file.isHittable, "A named sock should enable visible case filing")
        file.tap()

        let order = app.descendants(matching: .any).matching(identifier: "sockCourtOrder").firstMatch
        XCTAssertTrue(order.waitForExistence(timeout: 5), "Filing should issue an accessible court order")
        let orderValue = order.value as? String ?? ""
        XCTAssertTrue(orderValue.contains("one suspicious ankle sock"), "The order should identify the user's real case")
        XCTAssertTrue(orderValue.contains("missing 0 days"), "Today's filing should use the exact derived elapsed-day count")
        XCTAssertEqual(caseCount.value as? String, "1", "Filing should create one private docket entry")

        let summary = app.descendants(matching: .any).matching(identifier: "sockDocketSummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "The docket should expose useful status totals")
        XCTAssertEqual(summary.value as? String, "1 open, 0 reunited, oldest open 0 days", "The first open case should drive exact summary values")

        app.terminate()
        app.launch()
        let persistedCount = app.descendants(matching: .any).matching(identifier: "sockCaseCount").firstMatch
        XCTAssertTrue(persistedCount.waitForExistence(timeout: 8), "The docket should restore after relaunch")
        XCTAssertEqual(persistedCount.value as? String, "1", "The filed case should persist locally")

        let reunited = app.buttons["Reunited"]
        for _ in 0..<8 where !reunited.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(reunited.waitForExistence(timeout: 5), "An open case should support a real reunited state")
        XCTAssertTrue(reunited.isHittable, "The test should resolve the visible case")
        reunited.tap()
        XCTAssertEqual(summary.value as? String, "0 open, 1 reunited, oldest open none", "Reuniting should update status totals without deleting evidence")

        let reopen = app.buttons["Reopen search"]
        XCTAssertTrue(reopen.waitForExistence(timeout: 5), "A resolved case should be reversible")
        reopen.tap()
        let reopened = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1 open, 0 reunited, oldest open 0 days"),
            object: summary
        )
        XCTAssertEqual(XCTWaiter.wait(for: [reopened], timeout: 3), .completed, "Reopening should restore the active search")

        let close = app.buttons["Close unsolved"]
        XCTAssertTrue(close.waitForExistence(timeout: 5), "The user should be able to close an unsolved case explicitly")
        close.tap()
        XCTAssertEqual(summary.value as? String, "0 open, 0 reunited, oldest open none", "Unsolved closure should not be counted as a reunion")

        app.buttons["Delete case"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Individual deletion should return a one-case docket to empty")
        XCTAssertEqual(persistedCount.value as? String, "0", "Individual deletion should persist immediately")

        let secondSock = app.textFields["Describe the unmatched sock"]
        for _ in 0..<8 where !secondSock.isHittable {
            app.swipeDown()
        }
        XCTAssertTrue(secondSock.isHittable, "The filing desk should remain reusable after case deletion")
        secondSock.tap()
        secondSock.typeText("striped gym sock")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        for _ in 0..<5 where !file.isHittable {
            app.swipeUp()
        }
        file.tap()
        let eraseAfterRefiling = app.buttons["eraseSockArchiveButton"]
        for _ in 0..<8 where !eraseAfterRefiling.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(eraseAfterRefiling.isHittable, "Complete erasure should be a visible deliberate action")
        eraseAfterRefiling.tap()
        app.buttons["Confirm erase complete sock archive"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Confirmed erasure should remove every sock case")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should leave an empty docket")
    }

    @MainActor
    func testPlantCourtTracksWateringAndEdits() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app08plantcourt")
        app.launch()

        let erase = app.buttons["erasePlantArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Plant Court should expose complete private-archive erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase complete plant archive"].tap()
        }

        let empty = app.descendants(matching: .any).matching(identifier: "emptyPlantDocket").firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "First use should contain no fictional plants")
        let count = app.descendants(matching: .any).matching(identifier: "plantRecordCount").firstMatch
        XCTAssertEqual(count.value as? String, "0", "The private greenhouse should begin empty")

        let plant = app.textFields["Plant name"]
        XCTAssertTrue(plant.waitForExistence(timeout: 8), "Plant Court should accept a real plant name")
        plant.tap()
        plant.typeText("Fern")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }

        let species = app.textFields["Species or nickname (optional)"]
        species.tap()
        species.typeText("Boston fern")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }

        let reminder = app.switches["plantReminderToggle"]
        for _ in 0..<8 where !reminder.isHittable { app.swipeUp() }
        XCTAssertTrue(reminder.isHittable, "A plant can opt into one contextual care reminder")
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(reminder.value as? String, "1", "The user should explicitly opt into plant reminders")
        app.swipeUp()
        let notificationStatus = app.descendants(matching: .any).matching(identifier: "plantNotificationStatus").firstMatch
        XCTAssertTrue(notificationStatus.waitForExistence(timeout: 5), "Opt-in should explain the permission timing")
        XCTAssertTrue((notificationStatus.label + " " + (notificationStatus.value as? String ?? "")).contains("We’ll ask before turning this reminder on"), "Permission should be deferred until a reminded plant is saved")
        for _ in 0..<6 where !reminder.isHittable { app.swipeDown() }
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(reminder.value as? String, "0", "The base journey should avoid the system permission prompt")

        let save = app.buttons["savePlantRecordButton"]
        for _ in 0..<8 where !save.isHittable { app.swipeUp() }
        XCTAssertTrue(save.isEnabled && save.isHittable, "A named plant should enable visible saving")
        save.tap()

        let order = app.descendants(matching: .any).matching(identifier: "plantCareOrder").firstMatch
        XCTAssertTrue(order.waitForExistence(timeout: 5), "Saving should issue an exact care order")
        let orderValue = order.value as? String ?? ""
        XCTAssertTrue(orderValue.contains("Fern"), "The order should identify the user's plant")
        XCTAssertTrue(orderValue.contains("7-day rule"), "The order should publish the user-defined interval")
        XCTAssertEqual(count.value as? String, "1", "Saving should create one private plant record")

        let summary = app.descendants(matching: .any).matching(identifier: "plantCareSummary").firstMatch
        XCTAssertEqual(summary.value as? String, "1 plants, 0 due now, 1 watering entries", "Today's watering and seven-day interval should produce exact totals")

        app.terminate()
        app.launch()
        let persistedCount = app.descendants(matching: .any).matching(identifier: "plantRecordCount").firstMatch
        XCTAssertTrue(persistedCount.waitForExistence(timeout: 8), "The plant docket should restore after relaunch")
        XCTAssertEqual(persistedCount.value as? String, "1", "The real plant should persist locally")

        let watered = app.buttons["Watered now"]
        for _ in 0..<10 where !watered.isHittable { app.swipeUp() }
        XCTAssertTrue(watered.isHittable, "A plant record should support repeatable watering logs")
        watered.tap()
        XCTAssertEqual(summary.value as? String, "1 plants, 0 due now, 2 watering entries", "Watered now should append a real history entry")

        let edit = app.buttons["Edit record"]
        XCTAssertTrue(edit.isHittable, "A saved plant should be editable")
        edit.tap()
        let editingPlant = app.textFields["Plant name"]
        for _ in 0..<10 where !editingPlant.isHittable { app.swipeDown() }
        XCTAssertEqual(editingPlant.value as? String, "Fern", "Editing should restore the saved record into the filing desk")
        editingPlant.tap()
        editingPlant.typeText(" Junior")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        for _ in 0..<8 where !save.isHittable { app.swipeUp() }
        save.tap()
        XCTAssertEqual(persistedCount.value as? String, "1", "Editing should update instead of duplicating the plant")

        let delete = app.buttons["Delete plant record"]
        for _ in 0..<10 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Individual deletion should restore the truthful empty state")

        let second = app.textFields["Plant name"]
        for _ in 0..<10 where !second.isHittable { app.swipeDown() }
        second.tap()
        second.typeText("Pothos")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        for _ in 0..<8 where !save.isHittable { app.swipeUp() }
        save.tap()
        let eraseAfterRefiling = app.buttons["erasePlantArchiveButton"]
        for _ in 0..<10 where !eraseAfterRefiling.isHittable { app.swipeUp() }
        eraseAfterRefiling.tap()
        app.buttons["Confirm erase complete plant archive"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Confirmed erasure should remove every plant record")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should leave zero plants")
    }

    @MainActor
    func testLaundryMountainTracksCompleteBatchLifecycle() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app09laundrymountain")
        app.launch()

        let erase = app.buttons["eraseLaundryArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Laundry Mountain should expose complete archive erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase complete laundry archive"].tap()
        }

        let empty = app.descendants(matching: .any).matching(identifier: "emptyLaundryQueue").firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "First use should contain no fictional laundry")
        let count = app.descendants(matching: .any).matching(identifier: "laundryBatchCount").firstMatch
        XCTAssertEqual(count.value as? String, "0", "The queue should begin empty")

        let name = app.textFields["Batch name"]
        XCTAssertTrue(name.waitForExistence(timeout: 8), "A real batch should have a name")
        XCTAssertTrue(focusTextField(name, in: app), "The initial batch field should receive keyboard focus")
        name.typeText("Gym kit")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }

        let reminder = app.switches["laundryReminderToggle"]
        for _ in 0..<10 where !reminder.isHittable { app.swipeUp() }
        XCTAssertTrue(reminder.isHittable, "Timed stages should offer an explicit contextual reminder")
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(reminder.value as? String, "1", "The reminder must be opt-in")
        app.swipeUp()
        let notificationStatus = app.descendants(matching: .any).matching(identifier: "laundryNotificationStatus").firstMatch
        XCTAssertTrue(notificationStatus.waitForExistence(timeout: 5), "Opt-in should explain when permission is requested")
        XCTAssertTrue((notificationStatus.label + " " + (notificationStatus.value as? String ?? "")).contains("We’ll ask before turning stage reminders on"), "Saving alone should not request notification permission")
        for _ in 0..<8 where !reminder.isHittable { app.swipeDown() }
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(reminder.value as? String, "0", "The base lifecycle should avoid the system prompt")

        let save = app.buttons["saveLaundryBatchButton"]
        for _ in 0..<10 where !save.isHittable { app.swipeUp() }
        XCTAssertTrue(save.isEnabled && save.isHittable, "A named batch should enable visible saving")
        save.tap()

        let ticket = app.descendants(matching: .any).matching(identifier: "laundryExpeditionTicket").firstMatch
        XCTAssertTrue(ticket.waitForExistence(timeout: 5), "Saving should issue an accessible expedition ticket")
        XCTAssertTrue((ticket.value as? String ?? "").contains("2 loads remain"), "The default batch should truthfully queue two loads")
        XCTAssertEqual(count.value as? String, "1", "Saving should create one batch")
        let summary = app.descendants(matching: .any).matching(identifier: "laundryQueueSummary").firstMatch
        XCTAssertEqual(summary.value as? String, "1 active batches, 2 loads left, 0 finished loads", "The queue should expose exact initial totals")

        app.terminate()
        app.launch()
        let persistedCount = app.descendants(matching: .any).matching(identifier: "laundryBatchCount").firstMatch
        XCTAssertTrue(persistedCount.waitForExistence(timeout: 8), "The batch should restore after relaunch")
        XCTAssertEqual(persistedCount.value as? String, "1", "The queue should persist locally")

        func visibleButton(_ label: String) -> XCUIElement {
            let button = app.buttons[label]
            for _ in 0..<12 where !button.isHittable { app.swipeUp() }
            XCTAssertTrue(button.isHittable, "Expected visible stage action: \(label)")
            return button
        }

        visibleButton("Start washing").tap()
        XCTAssertTrue((ticket.value as? String ?? "").contains("45 minutes"), "Washing should use the user-entered expected duration")
        visibleButton("Move to dryer").tap()
        XCTAssertTrue((ticket.value as? String ?? "").contains("50 minutes"), "Drying should use the user-entered expected duration")
        visibleButton("Ready to fold").tap()
        visibleButton("Folded one load").tap()
        XCTAssertEqual(summary.value as? String, "1 active batches, 1 loads left, 1 finished loads", "Folding one load should return a two-load batch to Dirty")

        visibleButton("Edit batch").tap()
        let editingName = app.textFields["Batch name"]
        for _ in 0..<12 where !editingName.isHittable { app.swipeDown() }
        XCTAssertEqual(editingName.value as? String, "Gym kit", "Editing should restore the real batch")
        XCTAssertTrue(focusTextField(editingName, in: app), "The editing batch field should receive keyboard focus")
        editingName.typeText(" Weekend")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        for _ in 0..<10 where !save.isHittable { app.swipeUp() }
        save.tap()
        XCTAssertEqual(persistedCount.value as? String, "1", "Editing should update instead of duplicating")

        visibleButton("Start washing").tap()
        visibleButton("Move to dryer").tap()
        visibleButton("Ready to fold").tap()
        visibleButton("Folded one load").tap()
        XCTAssertEqual(summary.value as? String, "0 active batches, 0 loads left, 2 finished loads", "The second folded load should complete the batch")

        visibleButton("Reopen one load").tap()
        XCTAssertEqual(summary.value as? String, "1 active batches, 1 loads left, 1 finished loads", "Reopening should reverse one completed load")
        visibleButton("Delete laundry batch").tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Individual deletion should restore an empty queue")

        let second = app.textFields["Batch name"]
        for _ in 0..<12 where !second.isHittable { app.swipeDown() }
        XCTAssertTrue(focusTextField(second, in: app), "The second batch field should receive keyboard focus")
        second.typeText("Towels")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        for _ in 0..<10 where !save.isHittable { app.swipeUp() }
        save.tap()
        let eraseAfterRefiling = app.buttons["eraseLaundryArchiveButton"]
        for _ in 0..<12 where !eraseAfterRefiling.isHittable { app.swipeUp() }
        eraseAfterRefiling.tap()
        app.buttons["Confirm erase complete laundry archive"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Confirmed erasure should remove the complete laundry archive")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should leave zero batches")
    }

    @MainActor
    func testAmIEarlyCalculatesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app11amiearly")
        app.launch()

        let erase = app.buttons["erasePunctualityDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Am I Early should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase every arrival"].tap()
        }

        let occasion = app.textFields["Occasion (optional)"]
        XCTAssertTrue(occasion.waitForExistence(timeout: 5), "Am I Early should accept an optional occasion")
        occasion.tap()
        occasion.typeText("Dentist")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let action = app.buttons["punctualityButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Am I Early should expose punctuality")
        action.tap()
        let result = app.descendants(matching: .any).matching(identifier: "punctualityResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "A filed arrival should expose its verdict")
        XCTAssertTrue((result.value as? String)?.contains("Comfortably early") ?? false, "The default 12-minute offset should receive the correct verdict")
        let summary = app.descendants(matching: .any).matching(identifier: "punctualitySummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Punctuality history should expose useful totals")
        XCTAssertEqual(summary.value as? String, "1 filed, 1 not late, 0 late", "The early arrival should enter the not-late total")

        let slider = app.sliders["Minutes before the appointment"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5), "Am I Early should expose the signed arrival offset")
        slider.adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(slider.value as? String, "-30", "The lower slider bound should represent thirty minutes late")
        action.tap()
        XCTAssertTrue((result.value as? String)?.contains("causing a scene") ?? false, "Thirty minutes late should receive the severe late verdict")
        let balancedSummary = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2 filed, 1 not late, 1 late"),
            object: summary
        )
        XCTAssertEqual(XCTWaiter.wait(for: [balancedSummary], timeout: 3), .completed, "Early and late arrivals should be summarized separately")

        app.terminate()
        app.launch()
        let persistedOccasion = app.textFields["Occasion (optional)"]
        XCTAssertTrue(persistedOccasion.waitForExistence(timeout: 8), "The current arrival draft should restore after relaunch")
        XCTAssertEqual(persistedOccasion.value as? String, "Dentist", "The occasion should persist locally")
        let persistedSummary = app.descendants(matching: .any).matching(identifier: "punctualitySummary").firstMatch
        XCTAssertEqual(persistedSummary.value as? String, "2 filed, 1 not late, 1 late", "The arrival history should survive relaunch")

        let delete = app.buttons.matching(identifier: "deletePunctualityRecordButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual arrival deletion should be available")
        delete.tap()
        let oneRecord = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value BEGINSWITH %@", "1 filed"),
            object: persistedSummary
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneRecord], timeout: 3), .completed, "Deleting one arrival should preserve the other")

        app.buttons["resetPunctualityButton"].tap()
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["resetPunctualityButton"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetDisabled], timeout: 3), .completed, "Reset should clear only the current report")

        app.buttons["erasePunctualityDataButton"].tap()
        app.buttons["Confirm erase every arrival"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyPunctualityHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove every filed arrival")
        XCTAssertEqual(persistedSummary.value as? String, "0 filed, 0 not late, 0 late", "Complete erasure should zero every summary")
    }

    @MainActor
    func testPigeonClassifierIdentifiesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app12pigeonorseagull")
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "birdScannerStage").firstMatch.waitForExistence(timeout: 8), "Pigeon classifier should lead with the species scanner")
        let action = app.buttons["identifyBirdButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Pigeon classifier should expose identification")
        XCTAssertTrue(app.buttons["birdCameraButton"].waitForExistence(timeout: 5), "Pigeon classifier should offer camera capture alongside the photo library")
        action.tap()
        app.buttons["resetBirdGuessButton"].tap()
    }

    @MainActor
    func testToiletTimerAssessesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app13toilettimer")
        app.launchArguments.append("-toiletTimer.disableExternalPresentation")
        app.launch()

        let clearHistory = app.buttons["clearToiletHistoryButton"]
        XCTAssertTrue(clearHistory.waitForExistence(timeout: 8), "Toilet Timer should expose local history erasure")
        if clearHistory.isEnabled {
            clearHistory.tap()
            app.buttons["Confirm erase session history"].tap()
        }
        let reset = app.buttons["resetBathroomButton"]
        if reset.isEnabled {
            reset.tap()
        }

        let action = app.buttons["assessBathroomButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Toilet Timer should expose assessment")
        action.tap()
        sleep(2)

        let readout = app.descendants(matching: .any).matching(identifier: "liveTimerReadout").firstMatch
        XCTAssertTrue(readout.waitForExistence(timeout: 5), "The live timer should expose elapsed seconds")
        let beforeBackground = Int(((readout.value as? String) ?? "0").split(separator: " ").first ?? "0") ?? 0
        XCTAssertGreaterThanOrEqual(beforeBackground, 1, "The live timer should actually advance")

        XCUIDevice.shared.press(.home)
        sleep(2)
        app.activate()
        XCTAssertTrue(action.waitForExistence(timeout: 8), "The running session should return after foreground activation")
        let afterBackground = Int(((readout.value as? String) ?? "0").split(separator: " ").first ?? "0") ?? 0
        XCTAssertGreaterThanOrEqual(afterBackground - beforeBackground, 1, "Time spent outside the app must still be counted")

        app.terminate()
        sleep(2)
        app.launch()
        XCTAssertTrue(app.buttons["assessBathroomButton"].waitForExistence(timeout: 8), "A running session should restore after process relaunch")
        let afterRelaunch = Int(((app.descendants(matching: .any).matching(identifier: "liveTimerReadout").firstMatch.value as? String) ?? "0").split(separator: " ").first ?? "0") ?? 0
        XCTAssertGreaterThanOrEqual(afterRelaunch - afterBackground, 1, "Elapsed time must survive process termination and relaunch")

        sleep(1)
        app.buttons["assessBathroomButton"].tap()
        let result = app.descendants(matching: .any).matching(identifier: "toiletTimerResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "Stopping should create a local assessment")
        XCTAssertTrue((result.value as? String)?.contains("Acceptable") ?? false, "A short measured session should receive the short-session assessment")
        let count = app.descendants(matching: .any).matching(identifier: "toiletHistoryCount").firstMatch
        XCTAssertTrue(count.waitForExistence(timeout: 5), "A completed timer should enter the local log")
        XCTAssertEqual(count.value as? String, "1", "Exactly one live session should be filed")

        app.terminate()
        app.launch()
        let persistedCount = app.descendants(matching: .any).matching(identifier: "toiletHistoryCount").firstMatch
        XCTAssertTrue(persistedCount.waitForExistence(timeout: 8), "The complaint log should restore after relaunch")
        XCTAssertEqual(persistedCount.value as? String, "1", "The live session should persist locally")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Live")).firstMatch.waitForExistence(timeout: 5), "History should identify the measured session")

        let delete = app.buttons.matching(identifier: "deleteToiletSessionButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual session deletion should be available")
        delete.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyToiletHistory").firstMatch.waitForExistence(timeout: 5), "Deleting the only session should restore the empty log")

        let manual = app.buttons["assessManualEstimateButton"]
        XCTAssertTrue(manual.waitForExistence(timeout: 5), "The manual estimate fallback should have a real action")
        manual.tap()
        let manualCount = app.descendants(matching: .any).matching(identifier: "toiletHistoryCount").firstMatch
        let oneManual = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: manualCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneManual], timeout: 3), .completed, "A manual estimate should create one saved assessment")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Estimate")).firstMatch.waitForExistence(timeout: 5), "History should distinguish a manual estimate")

        app.buttons["resetBathroomButton"].tap()
        app.buttons["clearToiletHistoryButton"].tap()
        app.buttons["Confirm erase session history"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyToiletHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove the complete local history")
    }

    @MainActor
    func testEpisodeForecastCalculatesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app14onemoreepisode")
        app.launch()

        let erase = app.buttons["eraseEpisodeDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Episode app should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase every forecast"].tap()
        }

        let show = app.textFields["Show name (optional)"]
        XCTAssertTrue(show.waitForExistence(timeout: 5), "Episode forecasting should accept an optional show name")
        show.tap()
        show.typeText("Night Show")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let action = app.buttons["calculateTomorrowButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Episode app should expose forecasting")
        action.tap()
        let result = app.descendants(matching: .any).matching(identifier: "episodeForecastResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "The exact forecast should be accessible")
        let firstForecast = result.value as? String ?? ""
        XCTAssertTrue(firstForecast.contains("Watch time: 45 min"), "One default episode should preserve all 45 minutes instead of truncating to zero hours")
        XCTAssertTrue(firstForecast.contains("7 hr 15 min"), "The forecast should subtract exact runtime from the chosen eight-hour budget")
        let historyCount = app.descendants(matching: .any).matching(identifier: "episodeHistoryCount").firstMatch
        XCTAssertTrue(historyCount.waitForExistence(timeout: 5), "A forecast should enter private history")
        XCTAssertEqual(historyCount.value as? String, "1", "The first forecast should file one record")

        let episodes = app.sliders["Episodes"]
        XCTAssertTrue(episodes.waitForExistence(timeout: 5), "The real episode-count control should be accessible")
        episodes.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(episodes.value as? String, "8", "The upper bound should represent eight episodes")
        action.tap()
        let secondForecast = result.value as? String ?? ""
        XCTAssertTrue(secondForecast.contains("Watch time: 6 hr"), "Eight 45-minute episodes should equal exactly six hours")
        XCTAssertTrue(secondForecast.contains("budget left: 2 hr"), "The remaining chosen budget should be exact")
        let twoForecasts = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2"),
            object: historyCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [twoForecasts], timeout: 3), .completed, "Two calculations should create two records")

        app.terminate()
        app.launch()
        let persistedShow = app.textFields["Show name (optional)"]
        XCTAssertTrue(persistedShow.waitForExistence(timeout: 8), "Current forecast inputs should restore after relaunch")
        XCTAssertEqual(persistedShow.value as? String, "Night Show", "The show name should persist locally")
        let persistedCount = app.descendants(matching: .any).matching(identifier: "episodeHistoryCount").firstMatch
        XCTAssertEqual(persistedCount.value as? String, "2", "Forecast history should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteEpisodeForecastButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual forecast deletion should be available")
        delete.tap()
        let oneForecast = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneForecast], timeout: 3), .completed, "Deleting one forecast should preserve the other")

        app.buttons["resetEpisodeButton"].tap()
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["resetEpisodeButton"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetDisabled], timeout: 3), .completed, "Reset should clear only the current forecast")

        app.buttons["eraseEpisodeDataButton"].tap()
        app.buttons["Confirm erase every forecast"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyEpisodeHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove every forecast")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should zero history")
    }

    @MainActor
    func testClosetRulingAsksAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app15caniwearthisagain")
        app.launch()

        let erase = app.buttons["eraseWardrobeDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Closet app should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase every wardrobe ruling"].tap()
        }

        let item = app.textFields["Item or outfit name (optional)"]
        XCTAssertTrue(item.waitForExistence(timeout: 5), "Closet app should accept an optional garment name")
        item.tap()
        item.typeText("Blue Jacket")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let action = app.buttons["askClosetButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Closet app should expose its ruling")
        action.tap()

        let result = app.descendants(matching: .any).matching(identifier: "closetRulingResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "A transparent closet ruling should be accessible")
        XCTAssertTrue((result.value as? String)?.contains("Approved by your own rules") ?? false, "Default honest evidence should approve the projected second wear")
        XCTAssertTrue((result.value as? String)?.contains("2 of 3 allowed wears") ?? false, "Approval should show the exact personal-rule arithmetic")

        let historyCount = app.descendants(matching: .any).matching(identifier: "closetHistoryCount").firstMatch
        XCTAssertTrue(historyCount.waitForExistence(timeout: 5), "A ruling should enter private history")
        XCTAssertEqual(historyCount.value as? String, "1", "The first ruling should file one record")

        let completedWears = app.sliders["Completed wears since washing"]
        XCTAssertTrue(completedWears.waitForExistence(timeout: 5), "The actual wear-count control should be accessible")
        completedWears.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(completedWears.value as? String, "10", "The wear-count upper bound should be ten")
        action.tap()
        XCTAssertTrue((result.value as? String)?.contains("above your 3-wear limit") ?? false, "The app should enforce the user's own wear limit")

        let odor = app.switches["odorToggle"]
        XCTAssertTrue(odor.waitForExistence(timeout: 5), "Condition evidence should be an explicit real control")
        odor.tap()
        action.tap()
        XCTAssertTrue((result.value as? String)?.contains("You marked odor") ?? false, "Marked odor should take priority over elapsed resting time")

        let threeRulings = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "3"),
            object: historyCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [threeRulings], timeout: 3), .completed, "Three evidence paths should file three rulings")
        let summary = app.descendants(matching: .any).matching(identifier: "closetSummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Closet history should expose an outcome summary")
        XCTAssertEqual(summary.value as? String, "3 filed, 1 approved, 2 laundry", "Summary should separate approvals from laundry rulings")

        app.terminate()
        app.launch()
        let persistedItem = app.textFields["Item or outfit name (optional)"]
        XCTAssertTrue(persistedItem.waitForExistence(timeout: 8), "Current wardrobe evidence should restore after relaunch")
        XCTAssertEqual(persistedItem.value as? String, "Blue Jacket", "The garment name should persist locally")
        let persistedCount = app.descendants(matching: .any).matching(identifier: "closetHistoryCount").firstMatch
        XCTAssertEqual(persistedCount.value as? String, "3", "Closet history should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteClosetRulingButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual closet-ruling deletion should be available")
        delete.tap()
        let twoRulings = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2"),
            object: persistedCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [twoRulings], timeout: 3), .completed, "Deleting one ruling should preserve the others")

        app.buttons["resetOutfitButton"].tap()
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["resetOutfitButton"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetDisabled], timeout: 3), .completed, "Reset should clear only the current evidence")

        app.buttons["eraseWardrobeDataButton"].tap()
        app.buttons["Confirm erase every wardrobe ruling"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyClosetHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove every filed ruling")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should zero closet history")
    }

    @MainActor
    func testMicrowaveSommelierPairsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app16microwavesommelier")
        app.launch()

        let erase = app.buttons["eraseMicrowaveDataButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Microwave Sommelier should expose complete local-data erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase every conversion"].tap()
        }

        let food = app.textFields["What are you heating (optional)"]
        XCTAssertTrue(food.waitForExistence(timeout: 8), "Microwave Sommelier should expose food entry")
        food.tap()
        food.typeText("Tomato soup")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let action = app.buttons["pairHeatButton"]
        XCTAssertTrue(action.isEnabled, "A non-zero package time should enable conversion")
        action.tap()

        let result = app.descendants(matching: .any).matching(identifier: "microwaveConversionResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "The exact wattage conversion should be accessible")
        let firstConversion = result.value as? String ?? ""
        XCTAssertTrue(firstConversion.contains("Converted time: 5 min"), "Four minutes at 1000 W should convert to five minutes at 800 W")
        XCTAssertTrue(firstConversion.contains("4:00 at 1000 W → 5:00 at 800 W"), "The app should publish the exact source and target values")
        XCTAssertTrue(firstConversion.contains("First checkpoint: 4 min"), "The first checkpoint should equal 80 percent of the adjusted time")

        let historyCount = app.descendants(matching: .any).matching(identifier: "microwaveHistoryCount").firstMatch
        XCTAssertTrue(historyCount.waitForExistence(timeout: 5), "A conversion should enter private history")
        XCTAssertEqual(historyCount.value as? String, "1", "The first conversion should file one record")

        let wattage = app.sliders["Your microwave wattage"]
        XCTAssertTrue(wattage.waitForExistence(timeout: 5), "The actual appliance wattage control should be accessible")
        wattage.adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(wattage.value as? String, "500", "The lower appliance bound should be 500 W")
        action.tap()
        let secondConversion = result.value as? String ?? ""
        XCTAssertTrue(secondConversion.contains("Converted time: 8 min"), "Four minutes at 1000 W should convert to eight minutes at 500 W")
        XCTAssertTrue(secondConversion.contains("First checkpoint: 6 min 25 sec"), "The 80 percent checkpoint should round to the nearest five seconds")

        let twoConversions = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "2"),
            object: historyCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [twoConversions], timeout: 3), .completed, "Two conversions should file two records")

        app.terminate()
        app.launch()
        let persistedFood = app.textFields["What are you heating (optional)"]
        XCTAssertTrue(persistedFood.waitForExistence(timeout: 8), "Current microwave inputs should restore after relaunch")
        XCTAssertEqual(persistedFood.value as? String, "Tomato soup", "The optional food label should persist locally")
        let persistedCount = app.descendants(matching: .any).matching(identifier: "microwaveHistoryCount").firstMatch
        XCTAssertEqual(persistedCount.value as? String, "2", "Conversion history should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteMicrowaveConversionButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "Individual conversion deletion should be available")
        delete.tap()
        let oneConversion = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "1"),
            object: persistedCount
        )
        XCTAssertEqual(XCTWaiter.wait(for: [oneConversion], timeout: 3), .completed, "Deleting one conversion should preserve the other")

        app.buttons["resetMicrowaveButton"].tap()
        let resetDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: app.buttons["resetMicrowaveButton"]
        )
        XCTAssertEqual(XCTWaiter.wait(for: [resetDisabled], timeout: 3), .completed, "Reset should clear only the current pairing")

        app.buttons["eraseMicrowaveDataButton"].tap()
        app.buttons["Confirm erase every conversion"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyMicrowaveHistory").firstMatch.waitForExistence(timeout: 5), "Confirmed erasure should remove every conversion")
        XCTAssertEqual(persistedCount.value as? String, "0", "Complete erasure should zero microwave history")
    }

    @MainActor
    func testPeasantAdviceAnswersAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app19medievaladvice")
        app.launchArguments.append("-UITestingForceFallback")
        app.launch()
        app.buttons["resetPeasantButton"].tap()
        let editor = app.textFields["Your modern problem"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Peasant Advice should expose its question editor")
        editor.tap()
        editor.typeText("Should I take a nap?")
        app.buttons["seekWisdomButton"].tap()

        let status = app.descendants(matching: .any).matching(identifier: "modelStatus").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5), "Peasant Advice should disclose its model path")
        let completed = XCTNSPredicateExpectation(
            predicate: NSPredicate(
                format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                "village has spoken",
                "backup peasant"
            ),
            object: status
        )
        XCTAssertEqual(XCTWaiter.wait(for: [completed], timeout: 30), .completed, "Peasant advice should finish on-device or use its local fallback")

        let answer = app.descendants(matching: .any).matching(identifier: "peasantAnswer").firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 5), "Peasant Advice should expose its answer")
        XCTAssertFalse((answer.value as? String)?.contains("sharpening a stick") ?? true, "Generation should replace the initial placeholder")
        app.buttons["resetPeasantButton"].tap()
        let resetAnswer = app.descendants(matching: .any).matching(identifier: "peasantAnswer").firstMatch
        XCTAssertTrue(resetAnswer.waitForExistence(timeout: 3), "Reset should keep the empty result visible")
        let reset = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS[c] %@", "sharpening a stick"),
            object: resetAnswer
        )
        XCTAssertEqual(XCTWaiter.wait(for: [reset], timeout: 3), .completed, "Reset should restore the private empty state")
    }

    @MainActor
    func testVibeMeterMeasuresAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app21vibemeter")
        app.launch()
        let action = app.buttons["measureVibeButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Vibe Meter should expose measurement")
        action.tap()
        app.buttons["resetVibeButton"].tap()
    }

    @MainActor
    func testQuietCafeSavesPersistsAndClearsWithoutLocation() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app23quietcafe")
        app.launch()

        let manualPin = app.buttons["reviewCafeMapCenterButton"]
        XCTAssertTrue(manualPin.waitForExistence(timeout: 12), "Quiet Café should expose a no-permission map fallback")
        manualPin.tap()

        let name = app.textFields["cafeNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 8), "Quiet Café should open its private field report")
        XCTAssertTrue(focusTextField(name, in: app), "The café name field should receive keyboard focus")
        name.typeText("The Very Quiet Corner")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let save = app.buttons["saveCafeReviewButton"]
        if !save.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(save.waitForExistence(timeout: 5), "Quiet Café should expose its local save action")
        save.tap()

        XCTAssertTrue(app.staticTexts["The Very Quiet Corner"].waitForExistence(timeout: 8), "Saved café should appear in the private ledger")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["The Very Quiet Corner"].waitForExistence(timeout: 8), "Saved café should survive relaunch")

        let clear = app.buttons["clearCafeReviewsButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 5), "Quiet Café should expose clear-all for local data")
        clear.tap()
        app.buttons["Clear all café reviews"].tap()
        XCTAssertTrue(app.staticTexts["No ratings yet"].waitForExistence(timeout: 5), "Clear-all should restore the empty café ledger")
    }

    @MainActor
    func testQuietCafeSearchReachesAUsefulOutcome() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app23quietcafe")
        app.launch()

        let search = app.buttons["findCafesButton"]
        XCTAssertTrue(search.waitForExistence(timeout: 12), "Quiet Café should expose visible-region search")

        let status = app.descendants(matching: .any).matching(identifier: "quietCafeStatus").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5), "Quiet Café should expose search status")
        search.tap()

        let completed = XCTNSPredicateExpectation(
            predicate: NSPredicate(
                format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                "Found",
                "found no cafés",
                "search is taking a break"
            ),
            object: status
        )
        XCTAssertEqual(XCTWaiter.wait(for: [completed], timeout: 20), .completed, "Café search should return results or a truthful manual fallback")
    }

    @MainActor
    func testDogNameGuesserPresentsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app24dognameguesser")
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "dogEvidenceStage").firstMatch.waitForExistence(timeout: 8), "Dog Name Guesser should lead with the photo-evidence stage")
        let guess = app.textFields["Your guess"]
        XCTAssertTrue(guess.waitForExistence(timeout: 8), "Dog Name Guesser should expose a guess field")
        XCTAssertTrue(app.buttons["dogCameraButton"].waitForExistence(timeout: 5), "Dog Name Guesser should offer camera capture alongside the photo library")
        guess.tap()
        guess.typeText("Biscuit")
        app.buttons["presentDogNameButton"].tap()
        app.buttons["resetDogNameButton"].tap()
    }

    @MainActor
    func testWaitingRoomContinuesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app25waitingroom")
        app.launch()
        let action = app.buttons["continueWaitingButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Waiting Room should expose continuation")
        action.tap()
        app.buttons["resetWaitingRoomButton"].tap()
    }

    @MainActor
    func testNeighborNoiseTranslatesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app26neighbornoise")
        app.launch()
        let editor = app.textFields["Describe the sound"]
        XCTAssertTrue(editor.waitForExistence(timeout: 8), "Neighbor Noise should expose its sound field")
        editor.tap()
        editor.typeText("a suspicious thump")
        app.buttons["translateNeighborNoiseButton"].tap()
        app.buttons["resetNeighborNoiseButton"].tap()
    }

    @MainActor
    func testTinyMuseumOpensAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app27tinymuseum")
        app.launch()

        let clear = app.buttons["clearMuseumButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 8), "Tiny Museum should expose complete local deletion")
        if clear.isEnabled {
            clear.tap()
            app.buttons["Erase the complete museum"].tap()
        }

        let title = app.textFields["Object title"]
        XCTAssertTrue(title.waitForExistence(timeout: 8), "Tiny Museum should expose object entry")
        XCTAssertTrue(app.buttons["museumCameraButton"].waitForExistence(timeout: 5), "Tiny Museum should offer camera capture alongside the photo library")
        title.tap()
        title.typeText("A heroic paperclip")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        app.buttons["openTinyExhibitionButton"].tap()
        XCTAssertTrue(app.staticTexts["A heroic paperclip"].waitForExistence(timeout: 5), "The first exhibit should enter the private collection")

        title.tap()
        title.typeText("Receipt from Tuesday")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }
        app.buttons["openTinyExhibitionButton"].tap()
        XCTAssertTrue(app.staticTexts["Receipt from Tuesday"].waitForExistence(timeout: 5), "The museum should support more than one exhibit")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["A heroic paperclip"].waitForExistence(timeout: 8), "The first exhibit should survive relaunch")
        XCTAssertTrue(app.staticTexts["Receipt from Tuesday"].exists, "The complete catalog should survive relaunch")

        let deaccession = app.buttons["Deaccession exhibit"].firstMatch
        XCTAssertTrue(deaccession.waitForExistence(timeout: 5), "Individual exhibits should be removable")
        deaccession.tap()
        let removedExhibit = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: app.staticTexts["Receipt from Tuesday"]
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [removedExhibit], timeout: 3),
            .completed,
            "Removing the newest exhibit should update the catalog"
        )

        app.buttons["clearMuseumButton"].tap()
        app.buttons["Erase the complete museum"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyMuseumCatalog").firstMatch.waitForExistence(timeout: 5), "Confirmed clear-all should erase every local exhibit")
    }

    @MainActor
    func testOverthinkingBoardReachesAndClearsConclusion() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app28overthinkingboard")
        app.launch()

        let manageArchive = app.buttons["manageOverthinkingArchiveButton"]
        XCTAssertTrue(manageArchive.waitForExistence(timeout: 8), "Overthinking Board should expose private archive management")
        if manageArchive.isEnabled {
            manageArchive.tap()
            app.buttons["Erase all archived cases"].tap()
        }
        let clearBoard = app.buttons["clearOverthinkingButton"]
        if clearBoard.isEnabled {
            clearBoard.tap()
        }

        let worry = app.textFields["The worry"]
        XCTAssertTrue(worry.waitForExistence(timeout: 8), "Overthinking Board should expose its worry field")
        worry.tap()
        worry.typeText("I sent a period")
        let supporting = app.textFields["Evidence supporting it"]
        supporting.tap()
        supporting.typeText("The reply was short")
        let evidence = app.textFields["Evidence against it"]
        evidence.tap()
        evidence.typeText("They replied normally")
        let alternative = app.textFields["A less dramatic explanation"]
        alternative.tap()
        alternative.typeText("They were busy")
        let nextStep = app.textFields["One small next step"]
        nextStep.tap()
        nextStep.typeText("Wait until tomorrow")
        app.buttons["issueConclusionButton"].tap()

        let result = app.descendants(matching: .any).matching(identifier: "overthinkingResult").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "The board should expose its conclusion")
        XCTAssertTrue((result.value as? String)?.contains("Evidence mixed") ?? false, "The conclusion should reflect both sides instead of inventing certainty")
        XCTAssertTrue((result.value as? String)?.contains("Wait until tomorrow") ?? false, "The conclusion should retain the user's small next step")
        let archiveCount = app.descendants(matching: .any).matching(identifier: "overthinkingArchiveCount").firstMatch
        XCTAssertTrue(archiveCount.waitForExistence(timeout: 5), "A completed board should create a private case file")
        XCTAssertEqual(archiveCount.value as? String, "1", "Exactly one case should be archived")

        app.terminate()
        app.launch()
        let persistedWorry = app.textFields["The worry"]
        XCTAssertTrue(persistedWorry.waitForExistence(timeout: 8), "The current board should restore after relaunch")
        XCTAssertEqual(persistedWorry.value as? String, "I sent a period", "Draft evidence should persist locally")
        XCTAssertTrue(app.staticTexts["I sent a period"].waitForExistence(timeout: 5), "The archived case should survive relaunch")

        let delete = app.buttons.matching(identifier: "deleteOverthinkingCaseButton").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "The board should expose individual case deletion")
        delete.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "emptyOverthinkingArchive").firstMatch.waitForExistence(timeout: 5), "Deleting the case should restore the empty archive")

        app.buttons["clearOverthinkingButton"].tap()
        let issue = app.buttons["issueConclusionButton"]
        let issueDisabled = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isEnabled == false"),
            object: issue
        )
        XCTAssertEqual(XCTWaiter.wait(for: [issueDisabled], timeout: 3), .completed, "Clearing should remove the current worry")
        XCTAssertFalse(app.buttons["manageOverthinkingArchiveButton"].isEnabled, "An empty archive should disable its destructive controls")
    }

    @MainActor
    func testBenchReviewSavesPersistsAndClears() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app29benchreviews")
        app.launch()

        let reviewCenter = app.buttons["reviewMapCenterButton"]
        XCTAssertTrue(reviewCenter.waitForExistence(timeout: 12), "Bench Reviews should expose the map-center action")
        reviewCenter.tap()

        let name = app.textFields["benchNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 8), "Bench Reviews should open the private review editor")
        name.tap()
        name.typeText("The sunny bench")
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        let save = app.buttons["saveBenchReviewButton"]
        if !save.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(save.waitForExistence(timeout: 5), "Bench Reviews should expose the local save action")
        save.tap()

        XCTAssertTrue(app.staticTexts["The sunny bench"].waitForExistence(timeout: 8), "Saved bench should appear in the local ledger")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["The sunny bench"].waitForExistence(timeout: 8), "Saved bench should survive relaunch")

        let clear = app.buttons["clearBenchReviewsButton"]
        XCTAssertTrue(clear.waitForExistence(timeout: 5), "Bench Reviews should expose clear-all for local data")
        clear.tap()
        app.buttons["Clear all reviews"].tap()
        XCTAssertTrue(app.staticTexts["No benches on file"].waitForExistence(timeout: 5), "Clear-all should restore the empty ledger")
    }

    @MainActor
    func testHumanGPSGeneratesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app31humangps")
        app.launch()
        let landmark = app.textFields["Nearby landmark"]
        XCTAssertTrue(landmark.waitForExistence(timeout: 8), "Human GPS should expose landmark entry")
        landmark.tap()
        landmark.typeText("the bakery")
        app.buttons["generateDirectionsButton"].tap()
        app.buttons["resetHumanGPSButton"].tap()
    }

    @MainActor
    func testLastSliceRotatesFairlyAndPersistsHistory() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app32lastslice")
        app.launch()

        func visibleButton(_ identifier: String) -> XCUIElement {
            let button = app.buttons[identifier]
            for _ in 0..<10 where !button.isHittable { app.swipeUp() }
            XCTAssertTrue(button.isHittable, "Expected visible diplomacy action: \(identifier)")
            return button
        }

        let erase = app.buttons["eraseSliceArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "The Last Slice should expose complete private-archive erasure")
        if erase.isEnabled {
            for _ in 0..<10 where !erase.isHittable { app.swipeUp() }
            erase.tap()
            app.buttons["Confirm erase complete diplomacy archive"].tap()
        }
        for _ in 0..<10 { app.swipeDown() }

        let emptyRoster = app.descendants(matching: .any).matching(identifier: "emptySliceRoster").firstMatch
        let emptyHistory = app.descendants(matching: .any).matching(identifier: "emptySliceHistory").firstMatch
        XCTAssertTrue(emptyRoster.waitForExistence(timeout: 5), "First use should not invent participants")
        XCTAssertTrue(emptyHistory.waitForExistence(timeout: 5), "First use should not invent ruling history")

        let people = app.textFields["People involved"]
        for _ in 0..<10 where !people.isHittable { app.swipeDown() }
        XCTAssertTrue(people.waitForExistence(timeout: 8), "Last Slice should expose its real roster editor")
        people.tap()
        people.typeText("Alex, Sam, Jo")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }

        let eligible = app.descendants(matching: .any).matching(identifier: "slicePeopleInput").firstMatch
        XCTAssertEqual(eligible.value as? String, "3 eligible people", "The roster should trim and count the three actual participants")
        visibleButton("resolveSliceButton").tap()
        for _ in 0..<8 { app.swipeDown() }

        var active = app.descendants(matching: .any).matching(identifier: "activeSliceRuling").firstMatch
        XCTAssertTrue(active.waitForExistence(timeout: 5), "A fair ruling should expose its current candidate")
        var candidate = app.descendants(matching: .any).matching(identifier: "sliceCurrentCandidate").firstMatch
        XCTAssertTrue(candidate.waitForExistence(timeout: 5), "The selected candidate should be explicit")
        let firstCandidate = candidate.value as? String ?? ""
        XCTAssertTrue(["Alex", "Sam", "Jo"].contains(firstCandidate), "The first candidate must come from the user roster")

        app.terminate()
        app.launch()
        active = app.descendants(matching: .any).matching(identifier: "activeSliceRuling").firstMatch
        XCTAssertTrue(active.waitForExistence(timeout: 8), "The active tribunal should survive relaunch")
        candidate = app.descendants(matching: .any).matching(identifier: "sliceCurrentCandidate").firstMatch
        XCTAssertEqual(candidate.value as? String, firstCandidate, "Relaunch must not silently redraw the candidate")

        visibleButton("sliceCandidatePassedButton").tap()
        candidate = app.descendants(matching: .any).matching(identifier: "sliceCurrentCandidate").firstMatch
        XCTAssertTrue(candidate.waitForExistence(timeout: 5), "A pass should nominate another eligible person")
        let firstWinner = candidate.value as? String ?? ""
        XCTAssertNotEqual(firstWinner, firstCandidate, "A pass must remove that candidate for the current round")
        XCTAssertTrue((active.value as? String ?? "").contains("1 passes"), "The live ruling should retain its exact pass count")
        if ProcessInfo.processInfo.environment["CAPTURE_ACTIVE_SLICE"] == "1" {
            for _ in 0..<8 { app.swipeDown() }
            Thread.sleep(forTimeInterval: 45)
            return
        }
        visibleButton("sliceAwardButton").tap()

        let historyCount = app.descendants(matching: .any).matching(identifier: "sliceHistoryCount").firstMatch
        XCTAssertEqual(historyCount.value as? String, "1", "Awarding should create one private ruling")
        let summary = app.descendants(matching: .any).matching(identifier: "sliceHistorySummary").firstMatch
        XCTAssertTrue((summary.value as? String ?? "").contains("1 rulings, 1 awarded, 1 passes"), "Summary should preserve the award and pass")

        for _ in 0..<10 where !app.buttons["resolveSliceButton"].isHittable { app.swipeDown() }
        app.buttons["resolveSliceButton"].tap()
        for _ in 0..<8 { app.swipeDown() }
        candidate = app.descendants(matching: .any).matching(identifier: "sliceCurrentCandidate").firstMatch
        XCTAssertTrue(candidate.waitForExistence(timeout: 5), "A second ruling should select from the same retained roster")
        XCTAssertNotEqual(candidate.value as? String, firstWinner, "The fewest-awards rule should rotate away from the prior winner")
        visibleButton("sliceAwardButton").tap()
        XCTAssertEqual(historyCount.value as? String, "2", "A second completed award should append rather than replace history")

        let delete = app.buttons["Delete slice ruling"].firstMatch
        for _ in 0..<10 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        XCTAssertEqual(historyCount.value as? String, "1", "Individual ruling deletion should preserve the rest")

        let eraseAll = app.buttons["eraseSliceArchiveButton"]
        for _ in 0..<10 where !eraseAll.isHittable { app.swipeUp() }
        eraseAll.tap()
        app.buttons["Confirm erase complete diplomacy archive"].tap()
        XCTAssertTrue(emptyRoster.waitForExistence(timeout: 5), "Complete erasure should remove the roster")
        XCTAssertTrue(emptyHistory.waitForExistence(timeout: 5), "Complete erasure should remove all rulings")
        XCTAssertEqual(historyCount.value as? String, "0", "Complete erasure should leave zero rulings")
    }

    @MainActor
    func testQueueTrackerMeasuresProgressAndHistory() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app33queuepersonality")
        app.launch()

        let erase = app.buttons["eraseQueueArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Queue Tracker should expose complete private-archive erasure")
        if erase.isEnabled {
            erase.tap()
            app.buttons["Confirm erase complete queue archive"].tap()
        }

        let empty = app.descendants(matching: .any).matching(identifier: "emptyQueueHistory").firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "First use should contain no fictional queue history")
        let historyCount = app.descendants(matching: .any).matching(identifier: "queueHistoryCount").firstMatch
        XCTAssertEqual(historyCount.value as? String, "0", "The private wait log should begin empty")

        let name = app.textFields["Queue name or place"]
        XCTAssertTrue(name.waitForExistence(timeout: 8), "A real queue should have user-entered context")
        name.tap()
        name.typeText("Grocery checkout")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        let estimate = app.descendants(matching: .any).matching(identifier: "queueStartingEstimate").firstMatch
        XCTAssertTrue(estimate.waitForExistence(timeout: 5), "The fallback estimate should be visible before starting")
        XCTAssertTrue(estimate.label.contains("15m"), "Five people at three minutes each should publish a fifteen-minute fallback")

        let reminder = app.switches["queueReminderToggle"]
        for _ in 0..<8 where !reminder.isHittable { app.swipeUp() }
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(reminder.value as? String, "1", "Estimated-turn reminders should be explicitly opt-in")
        app.swipeUp()
        let status = app.descendants(matching: .any).matching(identifier: "queueNotificationStatus").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5), "Opt-in should explain permission timing")
        XCTAssertTrue((status.label + " " + (status.value as? String ?? "")).contains("We’ll ask before turning this reminder on"), "The system prompt should be deferred until a reminded queue starts")
        for _ in 0..<8 where !reminder.isHittable { app.swipeDown() }
        reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()

        let start = app.buttons["startQueueSessionButton"]
        for _ in 0..<8 where !start.isHittable { app.swipeUp() }
        XCTAssertTrue(start.isEnabled && start.isHittable, "A named queue should enable visible starting")
        start.tap()

        for _ in 0..<8 { app.swipeDown() }

        var progress = app.descendants(matching: .any).matching(identifier: "activeQueueCard").firstMatch
        XCTAssertTrue(progress.waitForExistence(timeout: 5), "An active queue should expose exact position and ETA")
        XCTAssertTrue((progress.value as? String ?? "").contains("5 people ahead, 0 served"), "The session should begin from real user inputs")

        app.terminate()
        app.launch()
        let active = app.descendants(matching: .any).matching(identifier: "activeQueueCard").firstMatch
        XCTAssertTrue(active.waitForExistence(timeout: 8), "The live queue should survive relaunch")
        progress = app.descendants(matching: .any).matching(identifier: "activeQueueCard").firstMatch
        XCTAssertTrue(progress.waitForExistence(timeout: 5), "Relaunch should restore the exact active progress")

        func visibleButton(_ label: String) -> XCUIElement {
            let button = app.buttons[label]
            for _ in 0..<10 where !button.isHittable { app.swipeUp() }
            XCTAssertTrue(button.isHittable, "Expected visible queue action: \(label)")
            return button
        }

        visibleButton("Person served").tap()
        XCTAssertTrue((progress.value as? String ?? "").contains("4 people ahead, 1 served"), "Observed service should reduce position and increase throughput count")
        visibleButton("Joined ahead").tap()
        XCTAssertTrue((progress.value as? String ?? "").contains("5 people ahead, 1 served"), "A reported joiner should increase only people ahead")
        visibleButton("Correct: one fewer ahead").tap()
        XCTAssertTrue((progress.value as? String ?? "").contains("4 people ahead, 1 served"), "A correction should not pretend someone was served")
        visibleButton("Person served").tap()
        XCTAssertTrue((progress.value as? String ?? "").contains("3 people ahead, 2 served"), "A second observation should remain exact")

        visibleButton("Reached front").tap()
        XCTAssertEqual(historyCount.value as? String, "1", "Finishing should create one private history record")
        let summary = app.descendants(matching: .any).matching(identifier: "queueHistorySummary").firstMatch
        XCTAssertTrue((summary.value as? String ?? "").contains("1 finished sessions"), "Lifetime summary should reflect the completed queue")
        XCTAssertTrue(app.staticTexts["REACHED FRONT"].waitForExistence(timeout: 5), "History should preserve the selected outcome")

        let delete = app.buttons["Delete queue session"]
        for _ in 0..<8 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Individual deletion should restore an empty history")

        let second = app.textFields["Queue name or place"]
        for _ in 0..<10 where !second.isHittable { app.swipeDown() }
        second.tap()
        second.typeText("Coffee line")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        for _ in 0..<8 where !start.isHittable { app.swipeUp() }
        start.tap()
        visibleButton("Left queue").tap()
        XCTAssertTrue(app.staticTexts["LEFT QUEUE"].waitForExistence(timeout: 5), "Leaving should preserve a distinct outcome")
        let eraseAfterHistory = app.buttons["eraseQueueArchiveButton"]
        for _ in 0..<10 where !eraseAfterHistory.isHittable { app.swipeUp() }
        eraseAfterHistory.tap()
        app.buttons["Confirm erase complete queue archive"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Confirmed erasure should remove every queue session")
        XCTAssertEqual(historyCount.value as? String, "0", "Complete erasure should leave zero queue sessions")
    }

    @MainActor
    func testWeatherOutfitGeneratesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app34weatheroutfit")
        app.launch()
        let outfit = app.textFields["Your outfit"]
        XCTAssertTrue(outfit.waitForExistence(timeout: 8), "Weather Outfit should expose outfit entry")
        outfit.tap()
        outfit.typeText("a very optimistic jacket")
        app.buttons["generateOutfitDefenseButton"].tap()
        app.buttons["resetWeatherOutfitButton"].tap()
    }

    @MainActor
    func testDoorIncidentLogPersistsEditsAndErases() throws {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app35doorwaspush")
        app.launch()

        func visibleButton(_ identifier: String) -> XCUIElement {
            let button = app.buttons[identifier]
            for _ in 0..<12 where !button.isHittable { app.swipeUp() }
            XCTAssertTrue(button.isHittable, "Expected visible door-log action: \(identifier)")
            return button
        }

        let erase = app.buttons["eraseDoorArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Door Log should expose complete private-archive erasure")
        if erase.isEnabled {
            for _ in 0..<12 where !erase.isHittable { app.swipeUp() }
            erase.tap()
            app.buttons["Confirm erase complete door archive"].tap()
        }
        for _ in 0..<12 { app.swipeDown() }

        let empty = app.descendants(matching: .any).matching(identifier: "emptyDoorHistory").firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "First use should contain no fictional door incidents")
        let historyCount = app.descendants(matching: .any).matching(identifier: "doorHistoryCount").firstMatch
        XCTAssertEqual(historyCount.value as? String, "0", "The private door log should begin empty")

        let place = app.textFields["Door or place"]
        for _ in 0..<10 where !place.isHittable { app.swipeUp() }
        XCTAssertTrue(place.waitForExistence(timeout: 8), "A real incident should require user-entered context")
        place.tap()
        place.typeText("Office lobby")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }

        let attempts = app.sliders["Wrong attempts"]
        for _ in 0..<8 where !attempts.isHittable { app.swipeUp() }
        XCTAssertTrue(attempts.isHittable, "Wrong attempts must be adjusted through a visible control")
        attempts.adjust(toNormalizedSliderPosition: 0.15)
        XCTAssertEqual(attempts.value as? String, "3", "The filed report should use the slider's actual three-attempt value")
        let clarity = app.sliders["Sign clarity"]
        XCTAssertTrue(clarity.isHittable, "Sign clarity must be adjusted through a visible control")
        clarity.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(clarity.value as? String, "5", "The test should file a painfully clear sign")
        visibleButton("saveDoorIncidentButton").tap()

        let summary = app.descendants(matching: .any).matching(identifier: "doorIncidentSummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "A filed case should update exact lifetime totals")
        XCTAssertEqual(summary.value as? String, "1 incidents, 3 wrong attempts, 1 clear signs ignored", "The first case should retain attempts and clarity")
        XCTAssertEqual(historyCount.value as? String, "1", "Filing should create exactly one case")
        if ProcessInfo.processInfo.environment["CAPTURE_DOOR_INCIDENT"] == "1" {
            app.swipeUp()
            app.swipeUp()
            Thread.sleep(forTimeInterval: 45)
            return
        }

        app.terminate()
        app.launch()
        XCTAssertTrue(summary.waitForExistence(timeout: 8), "The incident summary should survive relaunch")
        XCTAssertEqual(summary.value as? String, "1 incidents, 3 wrong attempts, 1 clear signs ignored", "Relaunch should retain the exact first report")

        let edit = app.buttons["Edit door incident"].firstMatch
        for _ in 0..<12 where !edit.isHittable { app.swipeUp() }
        edit.tap()
        let form = app.descendants(matching: .any).matching(identifier: "doorIncidentForm").firstMatch
        XCTAssertTrue(form.waitForExistence(timeout: 5), "Editing should restore the report into the form")
        XCTAssertTrue((form.value as? String ?? "").contains("Office lobby"), "Editing should preserve the original place")
        for _ in 0..<12 { app.swipeDown() }
        visibleButton("doorMistakepushedPull").tap()
        visibleButton("saveDoorIncidentButton").tap()
        XCTAssertEqual(historyCount.value as? String, "1", "Saving an edit must update rather than duplicate")
        XCTAssertTrue(app.staticTexts["PUSH → PULL"].waitForExistence(timeout: 5), "The corrected mistake direction should be visible in history")

        let secondPlace = app.textFields["Door or place"]
        for _ in 0..<12 where !secondPlace.isHittable { app.swipeDown() }
        secondPlace.tap()
        secondPlace.typeText("Cafe entrance")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        visibleButton("doorMistaketriedBoth").tap()
        visibleButton("saveDoorIncidentButton").tap()
        let freshHistoryCount = app.descendants(matching: .any).matching(identifier: "doorHistoryCount").firstMatch
        let twoCases = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "2"), object: freshHistoryCount)
        XCTAssertEqual(XCTWaiter.wait(for: [twoCases], timeout: 3), .completed, "A new real incident should appear in the local history")
        XCTAssertEqual(historyCount.value as? String, "2", "A new real incident should append to history")
        XCTAssertEqual(summary.value as? String, "2 incidents, 4 wrong attempts, 1 clear signs ignored", "Lifetime totals should combine the edited and new cases exactly")

        let deleteButtons = app.buttons.matching(identifier: "Delete door incident")
        var visibleDelete: XCUIElement?
        for _ in 0..<14 {
            visibleDelete = deleteButtons.allElementsBoundByIndex.first { $0.isHittable }
            if visibleDelete != nil { break }
            app.swipeUp()
        }
        XCTAssertNotNil(visibleDelete, "Individual deletion should use a visible history-row action")
        visibleDelete?.tap()
        let oneCase = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "1"), object: historyCount)
        XCTAssertEqual(XCTWaiter.wait(for: [oneCase], timeout: 3), .completed, "Individual deletion should preserve the remaining report")

        let eraseAll = app.buttons["eraseDoorArchiveButton"]
        for _ in 0..<12 where !eraseAll.isHittable { app.swipeUp() }
        eraseAll.tap()
        app.buttons["Confirm erase complete door archive"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Confirmed erasure should restore truthful empty history")
        XCTAssertEqual(historyCount.value as? String, "0", "Complete erasure should leave zero door cases")
    }

    @MainActor
    func testStepDebtCalculatesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app36stepdebt")
        app.launch()
        let health = app.buttons["importHealthStepsButton"]
        XCTAssertTrue(health.waitForExistence(timeout: 8), "Step Debt should expose the optional Apple Health connection")
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "stepDebtHealthCard").firstMatch.exists, "Step Debt should explain the read-only HealthKit path")
        XCTAssertTrue(app.buttons["findStepClosingRouteButton"].waitForExistence(timeout: 5), "Step Debt should offer a requested Apple Maps walking route")
        XCTAssertTrue(app.switches["stepDebtDailyNudgeSwitch"].waitForExistence(timeout: 5), "Step Debt should expose an opt-in daily check-in")
        let action = app.buttons["calculateStepDebtButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Step Debt should expose calculation")
        action.tap()
        app.buttons["resetStepDebtButton"].tap()
    }

    @MainActor
    func testSleepAlibiGeneratesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app37sleepalibi")
        app.launch()
        app.buttons["resetSleepAlibiButton"].tap()
        let health = app.buttons["importHealthSleepButton"]
        XCTAssertTrue(health.waitForExistence(timeout: 8), "Sleep Alibi should expose its optional HealthKit path")
        let fallbackStatus = app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Apple Health is optional"))
            .firstMatch
        XCTAssertTrue(fallbackStatus.waitForExistence(timeout: 5), "Sleep Alibi should explain that entering sleep remains available")
        let action = app.buttons["generateSleepAlibiButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Sleep Alibi should expose generation")
        for _ in 0..<6 where !action.isHittable { app.swipeUp() }
        action.tap()
        let reset = app.buttons["resetSleepAlibiButton"]
        for _ in 0..<6 where !reset.isHittable { app.swipeUp() }
        reset.tap()
    }

    @MainActor
    func testHeartRateEmailRecordsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app38heartrateemail")
        app.launch()
        let subject = app.textFields["Email subject"]
        XCTAssertTrue(subject.waitForExistence(timeout: 8), "Heart Rate Email should expose subject entry")
        subject.tap()
        subject.typeText("The email")
        app.buttons["recordEmailDramaButton"].tap()
        app.buttons["resetHeartRateEmailButton"].tap()
    }

    @MainActor
    func testWorkoutExcuseDetectsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app39workoutexcuse")
        app.launchArguments = ["-UITestingForceFallback"]
        app.launch()
        app.buttons["resetWorkoutExcuseButton"].tap()
        let health = app.buttons["importHealthWorkoutsButton"]
        XCTAssertTrue(health.waitForExistence(timeout: 8), "Workout Excuse should expose its optional HealthKit path")
        health.tap()
        let fallbackStatus = app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS %@", "Manual movement still works"))
            .firstMatch
        XCTAssertTrue(fallbackStatus.waitForExistence(timeout: 10), "Workout Excuse should keep its manual fallback when HealthKit is unavailable or denied")
        let excuse = app.textFields["Your excuse"]
        XCTAssertTrue(excuse.waitForExistence(timeout: 8), "Workout Excuse should expose excuse entry")
        XCTAssertTrue(focusTextField(excuse, in: app), "The workout excuse field should receive keyboard focus")
        excuse.typeText("my left sock felt ambitious")
        app.buttons["runWorkoutExcuseButton"].tap()
        app.buttons["resetWorkoutExcuseButton"].tap()
    }

    @MainActor
    func testHealthHoroscopeConsultsAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app40healthhoroscope")
        app.launch()
        XCTAssertTrue(app.buttons["connectHealthHoroscopeButton"].waitForExistence(timeout: 8), "Health Horoscope should expose its optional Apple Health path")
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "healthHoroscopeDisclaimer").firstMatch.exists, "Health Horoscope should keep the entertainment boundary visible")
        let action = app.buttons["consultHealthHoroscopeButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Health Horoscope should expose consultation")
        action.tap()
        app.buttons["resetHealthHoroscopeButton"].tap()
    }

    @MainActor
    func testRecoveryGoblinAnswersAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app41recoverygoblin")
        app.launch()
        XCTAssertTrue(app.buttons["importRecoveryHealthButton"].waitForExistence(timeout: 8), "Recovery Goblin should expose optional Apple Health context")
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "recoveryGoblinInputs").firstMatch.exists, "Recovery Goblin should keep self-reported signals as the primary input")
        let action = app.buttons["askRecoveryGoblinButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Recovery Goblin should expose its ruling")
        action.tap()
        app.buttons["resetRecoveryGoblinButton"].tap()
    }

    @MainActor
    func testWalkingMeetingTracksAgendaNotesAndOutcomes() throws {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app42walkingmeeting")
        app.launch()

        func visibleButton(_ identifier: String, scrolling direction: String = "up") -> XCUIElement {
            let button = app.buttons[identifier]
            for _ in 0..<14 where !button.isHittable {
                direction == "down" ? app.swipeDown() : app.swipeUp()
            }
            XCTAssertTrue(button.isHittable, "Expected visible walking-session action: \(identifier)")
            return button
        }

        let erase = app.buttons["eraseWalkingArchiveButton"]
        XCTAssertTrue(erase.waitForExistence(timeout: 8), "Walking Meeting should expose complete private-archive erasure")
        if erase.isEnabled {
            for _ in 0..<14 where !erase.isHittable { app.swipeUp() }
            erase.tap()
            app.buttons["Confirm erase complete walking archive"].tap()
        }
        for _ in 0..<14 { app.swipeDown() }

        let empty = app.descendants(matching: .any).matching(identifier: "emptyWalkingHistory").firstMatch
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "First use should contain no fictional walking meetings")
        let historyCount = app.descendants(matching: .any).matching(identifier: "walkingHistoryCount").firstMatch
        XCTAssertEqual(historyCount.value as? String, "0", "The private walk log should begin empty")

        let title = app.textFields["Meeting title"]
        for _ in 0..<10 where !title.isHittable { app.swipeUp() }
        XCTAssertTrue(title.waitForExistence(timeout: 8), "A real walking meeting should require a title")
        title.tap(); title.typeText("Product sync")
        let objective = app.textFields["One decision or objective"]
        objective.tap(); objective.typeText("Choose launch date")
        let route = app.textFields["Route or accessibility note (optional)"]
        route.tap(); route.typeText("Flat loop around the block")

        app.terminate(); app.launch()
        let restoredTitle = app.textFields["Meeting title"]
        XCTAssertTrue(restoredTitle.waitForExistence(timeout: 8), "The unsaved field plan should survive relaunch")
        XCTAssertEqual(restoredTitle.value as? String, "Product sync", "Relaunch should preserve the user-owned meeting draft")

        let reminder = app.switches.firstMatch
        for _ in 0..<10 where !reminder.isHittable { app.swipeUp() }
        XCTAssertTrue(reminder.waitForExistence(timeout: 5) && reminder.isHittable, "Reminder opt-in should be a visible contextual control")
        reminder.tap()
        XCTAssertEqual(reminder.value as? String, "1", "Planned-end reminders should be explicitly opt-in")
        let status = app.staticTexts.matching(
            NSPredicate(
                format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                "We’ll ask before turning this reminder on",
                "Notifications are available",
                "Notifications are disabled"
            )
        ).firstMatch
        for _ in 0..<6 where !status.exists { app.swipeUp() }
        XCTAssertTrue(status.waitForExistence(timeout: 5), "The reminder should explain its current state before the walk begins")
        for _ in 0..<6 where !reminder.isHittable { app.swipeDown() }
        reminder.tap()

        visibleButton("startWalkingMeetingButton").tap()
        for _ in 0..<12 { app.swipeDown() }
        var active = app.descendants(matching: .any).matching(identifier: "activeWalkingMeeting").firstMatch
        XCTAssertTrue(active.waitForExistence(timeout: 5), "Starting should expose a real live session")
        XCTAssertEqual(active.value as? String, "0 of 3 checkpoints, 0 notes, 30 planned minutes", "The live session should begin from exact user inputs")

        app.terminate(); app.launch()
        active = app.descendants(matching: .any).matching(identifier: "activeWalkingMeeting").firstMatch
        XCTAssertTrue(active.waitForExistence(timeout: 8), "The live timer and agenda should survive relaunch")

        visibleButton("walkCheckpointobjective").tap()
        visibleButton("walkCheckpointdecision").tap()
        let note = app.textFields["Decision or note"]
        for _ in 0..<10 where !note.isHittable { app.swipeUp() }
        note.tap(); note.typeText("Launch on Friday")
        if app.keyboards.buttons["Return"].exists { app.keyboards.buttons["Return"].tap() }
        visibleButton("addWalkingNoteButton").tap()
        XCTAssertEqual(active.value as? String, "2 of 3 checkpoints, 1 notes, 30 planned minutes", "Checkpoints and notes should remain exact")
        visibleButton("Finish meeting").tap()

        let summary = app.descendants(matching: .any).matching(identifier: "walkingHistorySummary").firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Finishing should update walking history totals")
        XCTAssertTrue((summary.value as? String ?? "").contains("1 walks, 1 completed"), "A normal finish should count as completed")
        XCTAssertEqual(historyCount.value as? String, "1", "The first walk should create one private record")
        XCTAssertTrue(app.staticTexts["COMPLETED"].waitForExistence(timeout: 5), "History should preserve the completed outcome")

        let secondTitle = app.textFields["Meeting title"]
        for _ in 0..<14 where !secondTitle.isHittable { app.swipeDown() }
        secondTitle.tap(); secondTitle.typeText("Hiring walk")
        let secondObjective = app.textFields["One decision or objective"]
        secondObjective.tap(); secondObjective.typeText("Choose interview panel")
        app.terminate(); app.launch()
        app.swipeUp()
        visibleButton("startWalkingMeetingButton").tap()
        for _ in 0..<12 { app.swipeDown() }
        visibleButton("End early").tap()
        XCTAssertEqual(historyCount.value as? String, "2", "An ended-early walk should append instead of replacing history")
        XCTAssertTrue(app.staticTexts["ENDED EARLY"].waitForExistence(timeout: 5), "History should distinguish an honest early ending")

        let deleteButtons = app.buttons.matching(identifier: "Delete walking meeting")
        var visibleDelete: XCUIElement?
        for _ in 0..<14 {
            visibleDelete = deleteButtons.allElementsBoundByIndex.first { $0.isHittable }
            if visibleDelete != nil { break }
            app.swipeUp()
        }
        XCTAssertNotNil(visibleDelete, "A visible history record should support individual deletion")
        visibleDelete?.tap()
        let oneWalk = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "1"), object: historyCount)
        XCTAssertEqual(XCTWaiter.wait(for: [oneWalk], timeout: 3), .completed, "Individual deletion should preserve the other walk")

        let eraseAll = app.buttons["eraseWalkingArchiveButton"]
        for _ in 0..<14 where !eraseAll.isHittable { app.swipeUp() }
        eraseAll.tap()
        app.buttons["Confirm erase complete walking archive"].tap()
        XCTAssertTrue(empty.waitForExistence(timeout: 5), "Complete erasure should restore truthful empty history")
        XCTAssertEqual(historyCount.value as? String, "0", "Complete erasure should leave zero walking meetings")
    }

    @MainActor
    func testRestDayPoliceIssuesAndResets() throws {
        let app = XCUIApplication(bundleIdentifier: "corp.unecessary.app44restdaypolice")
        app.launch()
        XCTAssertTrue(app.buttons["importRestDayHealthButton"].waitForExistence(timeout: 8), "Rest Day Police should expose optional Apple Health activity context")
        let action = app.buttons["issueRestDayCitationButton"]
        XCTAssertTrue(action.waitForExistence(timeout: 8), "Rest Day Police should expose citation")
        action.tap()
        app.buttons["resetRestDayPoliceButton"].tap()
    }

}
