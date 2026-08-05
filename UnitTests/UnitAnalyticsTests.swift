import XCTest
@testable import Unit

@MainActor
final class UnitAnalyticsTests: XCTestCase {
    private final class RecordingTransport: AnalyticsTransport {
        var initializedAppIDs: [String] = []
        var terminateCount = 0
        var signals: [(String, [String: String])] = []

        func initialize(appID: String) { initializedAppIDs.append(appID) }
        func terminate() { terminateCount += 1 }
        func send(name: String, parameters: [String: String]) {
            signals.append((name, parameters))
        }
    }

    private let appID = "11111111-1111-1111-1111-111111111111"

    func testDefaultsOnAndOptOutStopsFutureEventsImmediately() {
        let fixture = makeFixture(appIDProvider: { [appID] in appID })
        defer { fixture.defaults.removePersistentDomain(forName: fixture.suiteName) }
        let analytics = fixture.analytics
        let transport = fixture.transport
        XCTAssertTrue(analytics.isEnabled)
        analytics.configure()
        analytics.track(.workoutStarted)
        XCTAssertEqual(transport.signals.count, 1)

        analytics.setEnabled(false)
        analytics.track(.workoutCompleted(duration: .under15, setCount: .from1To5, noKeyboardRatio: .all))

        XCTAssertEqual(transport.signals.count, 1)
        XCTAssertEqual(transport.terminateCount, 1)
        XCTAssertFalse(analytics.isConfigured)
    }

    func testMissingConfigurationFailsClosed() {
        let fixture = makeFixture(appIDProvider: { nil })
        defer { fixture.defaults.removePersistentDomain(forName: fixture.suiteName) }
        let analytics = fixture.analytics
        let transport = fixture.transport
        analytics.configure()
        analytics.track(.paywallViewed(trialEligibility: "eligible"))

        XCTAssertTrue(transport.initializedAppIDs.isEmpty)
        XCTAssertTrue(transport.signals.isEmpty)
        XCTAssertFalse(analytics.isConfigured)
    }

    func testCustomEventAllowlistIsExact() {
        XCTAssertEqual(UnitAnalyticsEvent.allowedNames, [
            "onboarding_started", "onboarding_slide_viewed", "weight_unit_selected",
            "program_source_selected", "program_setup_completed", "paywall_viewed",
            "trial_started", "purchase_completed", "workout_started", "workout_completed",
            "progression_recommendation_shown", "progression_decision", "feedback_action"
        ])
    }

    func testPayloadsContainOnlyControlledValuesAndNoWorkoutContent() {
        let events: [UnitAnalyticsEvent] = [
            .onboardingSlideViewed(id: .nextTarget),
            .weightUnitSelected(unit: "kg"),
            .programSourceSelected(source: "paste"),
            .paywallViewed(trialEligibility: "eligible"),
            .purchaseCompleted(tier: "annual"),
            .workoutCompleted(duration: .from30To60, setCount: .from11To20, noKeyboardRatio: .from90To99),
            .progressionDecision(action: .edit, outcome: .addWeight),
            .feedbackAction(action: .book)
        ]
        let forbiddenKeys = Set([
            "exercise", "program", "weight", "reps", "note", "bodyweight", "email",
            "timestamp", "session_id", "exercise_id", "receipt"
        ])

        for event in events {
            let payload = event.payload
            XCTAssertTrue(UnitAnalyticsEvent.allowedNames.contains(payload.name))
            XCTAssertTrue(forbiddenKeys.isDisjoint(with: payload.parameters.keys))
            XCTAssertFalse(payload.parameters.values.contains("Bench Press"))
            XCTAssertFalse(payload.parameters.values.contains("60"))
        }
    }

    func testWorkoutBucketsNeverExposeExactValues() {
        XCTAssertEqual(AnalyticsDurationBucket.value(for: 1_234), .from15To30)
        XCTAssertEqual(AnalyticsSetCountBucket.value(for: 12), .from11To20)
        XCTAssertEqual(
            AnalyticsNoKeyboardRatioBucket.value(prefilledSets: 9, completedSets: 10),
            .from90To99
        )
    }

    private func makeFixture(
        appIDProvider: @escaping () -> String?
    ) -> (
        analytics: UnitAnalytics,
        transport: RecordingTransport,
        defaults: UserDefaults,
        suiteName: String
    ) {
        let suiteName = "UnitAnalyticsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let transport = RecordingTransport()
        let analytics = UnitAnalytics(
            defaults: defaults,
            transport: transport,
            appIDProvider: appIDProvider
        )
        return (analytics, transport, defaults, suiteName)
    }
}
