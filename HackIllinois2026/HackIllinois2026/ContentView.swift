import SwiftUI
import Combine

// MARK: - Theme (feminine + professional + empowering)

struct Theme {
    static let plum = Color(red: 0.36, green: 0.28, blue: 0.44)
    static let deepPlum = Color(red: 0.28, green: 0.21, blue: 0.35)
    static let softLavender = Color(red: 0.88, green: 0.85, blue: 0.94)

    static let accent = plum

    static let pageGradient = LinearGradient(
        colors: [
            Color(red: 0.90, green: 0.87, blue: 0.95),
            Color(red: 0.84, green: 0.80, blue: 0.92),
            Color(red: 0.78, green: 0.74, blue: 0.88)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBG = Color.white.opacity(0.78)
    static let cardStroke = plum.opacity(0.10)

    static let corner: CGFloat = 20
    static let cardPadding: CGFloat = 14
    static let pagePadding: CGFloat = 16

    static func titleStyle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .semibold, design: .serif))
            .foregroundStyle(plum)
    }

    static func secondaryStyle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(plum.opacity(0.65))
    }
}

// MARK: - ROYGBIV rainbow system (for mood colors)

enum MajorMoodHue: CaseIterable {
    case red, orange, yellow, green, blue, indigo, violet
    var hue: Double {
        switch self {
        case .red:    return 0.00
        case .orange: return 0.08
        case .yellow: return 0.15
        case .green:  return 0.33
        case .blue:   return 0.55
        case .indigo: return 0.65
        case .violet: return 0.78
        }
    }
}

func lerpHue(_ a: Double, _ b: Double, _ t: Double) -> Double {
    var delta = b - a
    if abs(delta) > 0.5 { delta -= delta.sign == .plus ? 1.0 : -1.0 }
    var h = a + delta * t
    if h < 0 { h += 1 }
    if h > 1 { h -= 1 }
    return h
}

func rainbowColor(position: Double, saturation: Double = 0.78, brightness: Double = 0.97) -> Color {
    let anchors = MajorMoodHue.allCases.map { $0.hue }.sorted()
    let p = min(max(position, 0), 1)

    let scaled = p * Double(anchors.count - 1)
    let i = Int(floor(scaled))
    let t = scaled - Double(i)

    let h1 = anchors[i]
    let h2 = anchors[min(i + 1, anchors.count - 1)]
    let hue = lerpHue(h1, h2, t)
    return Color(hue: hue, saturation: saturation, brightness: brightness)
}

// MARK: - Models

struct SymptomRating: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var rating: Int // 1...10
}

struct MoodTag: Identifiable, Hashable, Codable {
    var id = UUID()
    var label: String
    var position: Double // 0...1 across spectrum
    var major: String
}

struct LogEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var moods: [MoodTag]
    var symptoms: [SymptomRating]
    var journal: String
}

// MARK: - Mood Options

let moodOptions: [MoodTag] = [
    .init(label: "Overwhelmed", position: 0.01, major: "Stress"),
    .init(label: "Panicky", position: 0.03, major: "Stress"),
    .init(label: "On edge", position: 0.05, major: "Stress"),
    .init(label: "Overstimulated", position: 0.07, major: "Stress"),
    .init(label: "Frustrated", position: 0.09, major: "Stress"),

    .init(label: "Irritable", position: 0.11, major: "Tense"),
    .init(label: "Snappy", position: 0.12, major: "Tense"),
    .init(label: "Restless", position: 0.13, major: "Tense"),
    .init(label: "Uneasy", position: 0.14, major: "Tense"),
    .init(label: "Wired", position: 0.15, major: "Tense"),

    .init(label: "Low mood", position: 0.17, major: "Mood"),
    .init(label: "Sad", position: 0.18, major: "Mood"),
    .init(label: "Sensitive", position: 0.19, major: "Mood"),
    .init(label: "Tearful", position: 0.20, major: "Mood"),
    .init(label: "Unmotivated", position: 0.22, major: "Mood"),
    .init(label: "Self-critical", position: 0.24, major: "Mood"),

    .init(label: "Okay", position: 0.27, major: "Balance"),
    .init(label: "Stable", position: 0.30, major: "Balance"),
    .init(label: "Grounded", position: 0.32, major: "Balance"),
    .init(label: "Centered", position: 0.34, major: "Balance"),
    .init(label: "Hopeful", position: 0.36, major: "Balance"),

    .init(label: "Calm", position: 0.40, major: "Calm"),
    .init(label: "Peaceful", position: 0.42, major: "Calm"),
    .init(label: "Safe", position: 0.44, major: "Calm"),
    .init(label: "Patient", position: 0.46, major: "Calm"),
    .init(label: "In control", position: 0.48, major: "Calm"),

    .init(label: "Energized", position: 0.52, major: "Energy"),
    .init(label: "Motivated", position: 0.54, major: "Energy"),
    .init(label: "Social", position: 0.56, major: "Energy"),
    .init(label: "Confident", position: 0.58, major: "Energy"),
    .init(label: "Upbeat", position: 0.60, major: "Energy"),

    .init(label: "Focused", position: 0.63, major: "Clarity"),
    .init(label: "Clear-headed", position: 0.65, major: "Clarity"),
    .init(label: "Productive", position: 0.67, major: "Clarity"),
    .init(label: "Present", position: 0.69, major: "Clarity"),

    .init(label: "Foggy", position: 0.71, major: "Fatigue"),
    .init(label: "Drained", position: 0.74, major: "Fatigue"),
    .init(label: "Tired", position: 0.77, major: "Fatigue"),
    .init(label: "Exhausted", position: 0.80, major: "Fatigue"),
    .init(label: "Burned out", position: 0.83, major: "Fatigue"),
    .init(label: "Numb", position: 0.86, major: "Fatigue"),

    .init(label: "Heavy", position: 0.88, major: "Body"),
    .init(label: "Sluggish", position: 0.91, major: "Body"),
    .init(label: "Sleepy", position: 0.94, major: "Body"),
    .init(label: "Worn out", position: 0.97, major: "Body"),
]

// MARK: - Store

@MainActor
final class AppStore: ObservableObject {
    @Published var entries: [LogEntry] = []

    // Expanded based on the Mayo Clinic-style symptom lists you pasted.
    // These remain "informational indicators", not diagnoses.

    let pcosIndicators = [
        "Irregular periods",
        "Infrequent periods (few per year)",
        "Cycles > 35 days",
        "Periods lasting many days",
        "Trouble getting pregnant / ovulation issues",
        "Acne",
        "Excess facial/body hair (hirsutism)",
        "Hair thinning / male-pattern hair loss",
        "Weight changes / weight gain",
        "Increased appetite",
        "Insulin resistance signs (dark velvety skin patches)"
    ]

    let endoIndicators = [
        "Pelvic pain",
        "Painful periods (dysmenorrhea)",
        "Pain that starts before period and lasts into it",
        "Lower back pain around periods",
        "Stomach/abdominal pain around periods",
        "Pain during or after sex",
        "Pain with bowel movements (esp. around period)",
        "Pain with urination (esp. around period)",
        "Heavy menstrual bleeding",
        "Bleeding between periods",
        "Bloating",
        "Diarrhea",
        "Constipation",
        "Nausea",
        "Fatigue",
        "Infertility / trouble conceiving"
    ]

    // Match by symptom name (case-insensitive)
    func matchedIndicators(_ indicators: [String]) -> Set<String> {
        let logged = Set(entries.flatMap { $0.symptoms.map { $0.name.lowercased() } })
        return Set(indicators.filter { logged.contains($0.lowercased()) })
    }

    func countIndicatorsMatched(indicators: [String]) -> Int {
        matchedIndicators(indicators).count
    }

    func generateNextVisitPlan(userNotes: String, chartNotes: String) -> String {
        guard !entries.isEmpty else {
            return "No logs yet. Add a few entries first so I can pull patterns for your next visit."
        }

        let sorted = entries.sorted { $0.date < $1.date }
        let start = sorted.first!.date.formatted(date: .abbreviated, time: .omitted)
        let end = sorted.last!.date.formatted(date: .abbreviated, time: .omitted)

        let allMoods = entries.flatMap { $0.moods.map { $0.label } }
        let moodCounts = Dictionary(grouping: allMoods, by: { $0 }).mapValues { $0.count }
        let topMoods = moodCounts.sorted { $0.value > $1.value }.prefix(5)

        let allSymptoms = entries.flatMap { $0.symptoms }
        let grouped = Dictionary(grouping: allSymptoms, by: { $0.name })
        let topSymptoms = grouped
            .map { (name, vals) in
                let avg = Double(vals.map { $0.rating }.reduce(0, +)) / Double(vals.count)
                let maxV = vals.map { $0.rating }.max() ?? 0
                return (name: name, count: vals.count, avg: avg, maxV: maxV)
            }
            .sorted { $0.count > $1.count }
            .prefix(6)

        let userText = userNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        let chartText = chartNotes.trimmingCharacters(in: .whitespacesAndNewlines)

        var s = ""
        s += "NEXT VISIT PLAN\n"
        s += "Log window: \(start) – \(end)\n"
        s += "Entries: \(entries.count)\n\n"

        s += "1) What I want to discuss (my words)\n"
        s += userText.isEmpty ? "• (Add your notes below)\n\n" : "• \(userText)\n\n"

        s += "2) Patterns from my logs\n"
        if topSymptoms.isEmpty {
            s += "• Symptoms: (none logged)\n"
        } else {
            s += "• Top symptoms:\n"
            for t in topSymptoms {
                s += String(format: "  - %@ (%d days), avg %.1f/10, max %d/10\n", t.name, t.count, t.avg, t.maxV)
            }
        }

        if topMoods.isEmpty {
            s += "\n• Moods: (none selected)\n\n"
        } else {
            s += "\n• Common moods:\n"
            for (m, c) in topMoods { s += "  - \(m) (\(c) days)\n" }
            s += "\n"
        }

        s += "3) Optional: pasted chart/clinician notes\n"
        s += chartText.isEmpty ? "• (Nothing pasted)\n\n" : "• \(chartText)\n\n"

        s += "4) Suggested questions / talking points\n"
        s += "• What diagnoses are you considering, and what criteria would confirm/deny them?\n"
        s += "• What tests or imaging are appropriate (and what would each one rule in/out)?\n"
        s += "• What are my treatment options now vs later (pain, cycle regulation, fertility goals)?\n"
        s += "• What red flags should prompt urgent care?\n"
        s += "• If symptoms persist, what is the stepwise plan and timeline for follow-up?\n\n"

        s += "Notes:\n"
        s += "• This tool does not diagnose. It organizes your notes + your logs to support evaluation.\n"
        s += "• Only paste chart text you feel comfortable sharing.\n"
        return s
    }
}

struct IndicatorChecklistCard: View {
    let title: String
    let indicators: [String]
    let matched: Set<String>

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Theme.titleStyle(title)
                    Spacer()
                    Text("\(matched.count)/\(indicators.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.plum.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(indicators, id: \.self) { item in
                        let isOn = matched.contains(item)

                        HStack(spacing: 10) {
                            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isOn ? Theme.accent : Theme.plum.opacity(0.25))

                            Text(item)
                                .foregroundStyle(isOn ? Theme.deepPlum : Theme.plum.opacity(0.85))

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }

                Theme.secondaryStyle("Informational indicators — not diagnoses.")
            }
        }
    }
}

// MARK: - Reusable UI Pieces

struct ThemedBackground: View {
    var body: some View {
        Theme.pageGradient
            .ignoresSafeArea()
            .overlay(
                RadialGradient(
                    colors: [Theme.deepPlum.opacity(0.22), .clear],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 520
                )
                .ignoresSafeArea()
            )
            .overlay(
                RadialGradient(
                    colors: [Theme.plum.opacity(0.16), .clear],
                    center: .bottomLeading,
                    startRadius: 40,
                    endRadius: 560
                )
                .ignoresSafeArea()
            )
    }
}

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(Theme.cardPadding)
            .background(Theme.cardBG)
            .clipShape(RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .strokeBorder(Theme.cardStroke, lineWidth: 1)
            )
            .shadow(color: Theme.plum.opacity(0.06), radius: 18, x: 0, y: 8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.accent, Theme.plum.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .shadow(color: Theme.accent.opacity(0.20), radius: 18, x: 0, y: 8)
    }
}

// MARK: - Flow Layout (no overlap)

struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Mood Bubbles

struct MoodBubble: View {
    let tag: MoodTag
    let selected: Bool

    private var base: Color {
        rainbowColor(position: tag.position, saturation: selected ? 0.92 : 0.78, brightness: 0.98)
    }
    private var highlight: Color {
        rainbowColor(position: min(tag.position + 0.03, 1.0), saturation: 0.98, brightness: 1.0)
    }

    var body: some View {
        Text(tag.label)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(selected ? .white : Theme.deepPlum.opacity(0.95))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [highlight, base],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(selected ? 1.0 : 0.18)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        selected ? .white.opacity(0.45) : Theme.plum.opacity(0.14),
                        lineWidth: selected ? 1.6 : 1.0
                    )
            )
            .shadow(color: base.opacity(selected ? 0.25 : 0.05), radius: selected ? 10 : 5, x: 0, y: selected ? 7 : 3)
            .scaleEffect(selected ? 1.04 : 1.0)
            .animation(.snappy(duration: 0.18), value: selected)
            .contentShape(Capsule())
    }
}

struct MoodBubbleCloud: View {
    let options: [MoodTag]
    @Binding var selected: Set<MoodTag>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.softLavender.opacity(0.65))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Theme.plum.opacity(0.10), lineWidth: 1)
                    )

                ScrollView {
                    FlowLayout(spacing: 10) {
                        ForEach(options) { tag in
                            let isSelected = selected.contains(tag)
                            MoodBubble(tag: tag, selected: isSelected)
                                .onTapGesture {
                                    if isSelected { selected.remove(tag) }
                                    else { selected.insert(tag) }
                                }
                        }
                    }
                    .padding(12)
                }
                .scrollIndicators(.hidden)
            }
            .frame(height: 260)

            if selected.isEmpty {
                Theme.secondaryStyle("Tap bubbles that match your day (multi-select).")
            } else {
                Theme.secondaryStyle("Selected: " + selected.map { $0.label }.sorted().joined(separator: " • "))
            }
        }
    }
}

// MARK: - App Shell

struct ContentView: View {
    @StateObject private var store = AppStore()

    var body: some View {
        TabView {
            LogView()
                .tabItem { Label("Log", systemImage: "sparkles") }

            InsightsView()
                .tabItem { Label("Insights", systemImage: "checklist") }

            NextVisitPlanView()
                .tabItem { Label("Next Visit", systemImage: "stethoscope") }
        }
        .tint(Theme.accent)
        .environmentObject(store)
    }
}

// MARK: - Log Screen

struct LogView: View {
    @EnvironmentObject var store: AppStore

    @State private var date = Date()
    @State private var selectedMoods: Set<MoodTag> = []
    @State private var symptomName = ""
    @State private var symptomRating = 5
    @State private var symptoms: [SymptomRating] = []
    @State private var journal = ""

    @FocusState private var focusedField: Field?
    enum Field { case symptom, journal }

    var body: some View {
        NavigationStack {
            ZStack {
                ThemedBackground()

                ScrollView {
                    VStack(spacing: 14) {

                        Card {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Theme.titleStyle("Today")
                                    Theme.secondaryStyle("Log how you’re feeling — patterns matter.")
                                }
                                Spacer()
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                        }

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Mood / What applies")
                                MoodBubbleCloud(options: moodOptions, selected: $selectedMoods)
                            }
                        }

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Symptoms")

                                HStack(spacing: 10) {
                                    TextField("e.g., Pelvic pain", text: $symptomName)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($focusedField, equals: .symptom)

                                    Stepper("", value: $symptomRating, in: 1...10)
                                        .labelsHidden()
                                }

                                HStack {
                                    Theme.secondaryStyle("Severity: \(symptomRating)/10")
                                    Spacer()
                                    Button("Add") {
                                        let t = symptomName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !t.isEmpty else { return }
                                        symptoms.append(.init(name: t, rating: symptomRating))
                                        symptomName = ""
                                        symptomRating = 5
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.accent)
                                    .disabled(symptomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }

                                if !symptoms.isEmpty {
                                    VStack(spacing: 8) {
                                        ForEach(symptoms) { s in
                                            HStack {
                                                Text(s.name).foregroundStyle(Theme.plum)
                                                Spacer()
                                                Text("\(s.rating)/10").foregroundStyle(Theme.plum.opacity(0.65))
                                            }
                                            .padding(10)
                                            .background(.thinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .strokeBorder(Theme.plum.opacity(0.08), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Journal")

                                TextEditor(text: $journal)
                                    .focused($focusedField, equals: .journal)
                                    .frame(height: 120)
                                    .padding(10)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Theme.plum.opacity(0.08), lineWidth: 1)
                                    )

                                Theme.secondaryStyle("Optional: context, triggers, cycle notes, meds, etc.")
                            }
                        }

                        Button {
                            let entry = LogEntry(
                                date: date,
                                moods: selectedMoods.sorted { $0.label < $1.label },
                                symptoms: symptoms,
                                journal: journal
                            )
                            store.entries.insert(entry, at: 0)

                            selectedMoods = []
                            symptoms = []
                            journal = ""
                            focusedField = nil
                        } label: {
                            Text("Save Entry")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(symptoms.isEmpty && journal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(Theme.pagePadding)
                }
            }
            .navigationTitle("Symptom Log")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
    }
}

struct IndicatorDropdownCard: View {
    let title: String
//    let subtitle: String?
    let indicators: [String]
    let matched: Set<String>

    @State private var expanded = false

    var body: some View {
        Card {
            DisclosureGroup(isExpanded: $expanded) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(indicators, id: \.self) { item in
                        let isMatched = matched.contains(item)

                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Circle()
                                .fill(isMatched ? Theme.accent : Theme.plum.opacity(0.20))
                                .frame(width: 8, height: 8)

                            Text(item)
                                .foregroundStyle(isMatched ? Theme.deepPlum : Theme.plum.opacity(0.85))

                            Spacer()

                            if isMatched {
                                Text("logged")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.accent)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Theme.accent.opacity(0.10))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 2)
                    }

                    Theme.secondaryStyle("Informational indicators — not diagnoses.")
                        .padding(.top, 6)
                }
                .padding(.top, 8)
            } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.plum)

//                        if let subtitle {
//                            Text(subtitle)
//                                .font(.system(size: 12, weight: .medium, design: .rounded))
//                                .foregroundStyle(Theme.plum.opacity(0.65))
//                        }
                    }

                    Spacer()

                }
            }
            .accentColor(Theme.accent)
        }
    }
}

// MARK: - Insights Screen

struct InsightsView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                ThemedBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        let pcosMatched = store.matchedIndicators(store.pcosIndicators)
                        let endoMatched = store.matchedIndicators(store.endoIndicators)

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Insights")
                                Theme.secondaryStyle("This highlights patterns you’ve logged (not a diagnosis).")

                                HStack {
                                    Text("Entries logged").foregroundStyle(Theme.plum)
                                    Spacer()
                                    Text("\(store.entries.count)")
                                        .foregroundStyle(Theme.plum.opacity(0.65))
                                }
                            }
                        }

                        IndicatorDropdownCard(
                            title: "PCOS Common Symptoms",
//                            subtitle: "Tap to expand",
                            indicators: store.pcosIndicators,
                            matched: pcosMatched
                        )

                        IndicatorDropdownCard(
                            title: "Endometriosis Common Symptoms",
//                            subtitle: "Tap to expand",
                            indicators: store.endoIndicators,
                            matched: endoMatched
                        )
                    }
                    .padding(Theme.pagePadding)
                }
            }
            .navigationTitle("Insights")
        }
    }
}

// MARK: - Visit Brief Screen

struct NextVisitPlanView: View {
    @EnvironmentObject var store: AppStore

    @State private var myNotes = ""
    @State private var chartNotes = ""
    @State private var plan = ""

    @FocusState private var focusedField: Field?
    enum Field { case myNotes, chartNotes }

    var body: some View {
        NavigationStack {
            ZStack {
                ThemedBackground()

                ScrollView {
                    VStack(spacing: 14) {

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Next Visit Plan")
                                Theme.secondaryStyle("Write what you want to cover. I’ll pull patterns from your logs + format talking points.")
                            }
                        }

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("What I want to discuss")
                                TextEditor(text: $myNotes)
                                    .focused($focusedField, equals: .myNotes)
                                    .frame(height: 120)
                                    .padding(10)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Theme.plum.opacity(0.08), lineWidth: 1)
                                    )

                                Theme.secondaryStyle("Examples: pain pattern, cycle changes, fatigue, fertility goals, meds tried, what’s getting worse/better.")
                            }
                        }

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Optional: paste chart / clinician notes")
                                TextEditor(text: $chartNotes)
                                    .focused($focusedField, equals: .chartNotes)
                                    .frame(height: 120)
                                    .padding(10)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Theme.plum.opacity(0.08), lineWidth: 1)
                                    )

                                Theme.secondaryStyle("Only paste what you’re comfortable sharing. This stays on-device unless you later add networking.")
                            }
                        }

                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Theme.titleStyle("Generated plan")
                                Text(plan.isEmpty ? "Tap Generate to create your plan." : plan)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.plum.opacity(0.90))
                                    .padding(10)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Theme.plum.opacity(0.08), lineWidth: 1)
                                    )
                            }
                        }

                        HStack(spacing: 10) {
                            Button {
                                plan = store.generateNextVisitPlan(userNotes: myNotes, chartNotes: chartNotes)
                                focusedField = nil
                            } label: {
                                Text("Generate")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            if !plan.isEmpty {
                                Button {
                                    UIPasteboard.general.string = plan
                                } label: {
                                    Text("Copy")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(Theme.accent)
                            }
                        }
                    }
                    .padding(Theme.pagePadding)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Next Visit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
    }
}
