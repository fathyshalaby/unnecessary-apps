import SwiftUI
import DumbKit

@main
struct MeetingBingoApp: App {
    var body: some Scene {
        WindowGroup { MeetingBingoView().dumbNativeEntry(scheme: "app17meetingbingo") { _, _ in } }
    }
}

struct MeetingBingoView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let boardKey = "meetingBingo.board"
    private static let markedKey = "meetingBingo.marked"

    private let phrasePool = [
        "Circle back", "Quick question", "You’re on mute", "Synergy",
        "Take it offline", "Low-hanging fruit", "Deep dive", "Parking lot",
        "Bandwidth", "Move the needle", "Action items", "Let’s align",
        "Think outside the box", "Boil the ocean", "Touch base", "North star",
        "Per my last email", "Hard stop", "Big picture", "Level set",
        "Going forward", "Table that", "Value add", "Can everyone see my screen?"
    ]

    @State private var board: [String] = []
    @State private var marked = Set<Int>()
    @State private var winningLineIndices: [Int] = []
    @State private var gameRevision = 0
    @State private var showEraseConfirmation = false
    @AppStorage("meetingBingo.completed") private var completedGames = 0
    @AppStorage("meetingBingo.currentBoardWon") private var currentBoardWon = false

    var body: some View {
        ZStack {
            CorpPalette.canvas.ignoresSafeArea()
            LinearGradient(
                colors: [CorpPalette.courtroomNavy.opacity(0.10), CorpPalette.canvas],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                bingoToolbar
                ScrollView {
                    VStack(spacing: DumbSpacing.md) {
                        gameHeader

                        if board.count == 9 {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                                spacing: 10
                            ) {
                                ForEach(board.indices, id: \.self) { index in
                                    squareButton(index: index)
                                }
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Meeting bingo board")
                            .id(gameRevision)
                        } else {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 280)
                        }

                        DumbResult(
                            text: resultText,
                            accent: CorpPalette.courtroomNavy,
                            systemImage: hasBingo ? "trophy.fill" : "rectangle.grid.2x2.fill",
                            reactionStyle: hasBingo ? .stamp : .bounce
                        )
                        .accessibilityIdentifier("meetingBingoResult")

                        Button {
                            newGame()
                        } label: {
                            Label("Deal a new meeting", systemImage: "shuffle")
                                .font(.subheadline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .foregroundStyle(CorpPalette.courtroomNavy)
                        .buttonStyle(DumbPressStyle())
                        .accessibilityIdentifier("newMeetingButton")

                        Button {
                            showEraseConfirmation = true
                        } label: {
                            Label("Erase the board history", systemImage: "trash.fill")
                                .font(.subheadline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .foregroundStyle(CorpPalette.courtroomNavy)
                        .buttonStyle(DumbPressStyle())
                        .accessibilityIdentifier("eraseBingoDataButton")
                        .accessibilityHint("Asks for confirmation before resetting the board and completed-game count.")
                    }
                    .padding(.horizontal, DumbSpacing.md)
                    .padding(.bottom, DumbSpacing.xl)
                }
                .scrollIndicators(.hidden)
            }
        }
        .tint(CorpPalette.courtroomNavy)
        .environment(\.dumbExperienceStyle, .game)
        .onAppear(perform: restoreGame)
        .confirmationDialog(
            "Erase the active board and completed-game count?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase the board history", role: .destructive, action: eraseAllData)
            Button("Keep the meeting alive", role: .cancel) {}
        } message: {
            Text("This clears the board and completed-game count. It cannot be undone.")
        }
    }

    private var bingoToolbar: some View {
        HStack(alignment: .center, spacing: DumbSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CORPORATE WILDLIFE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.courtroomNavy)
                Text("Meeting bingo")
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 0)
            Image("AppMascot", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .padding(4)
                .background(CorpPalette.courtroomNavy.opacity(0.10), in: Circle())
                .accessibilityHidden(true)
        }
        .padding(.horizontal, DumbSpacing.md)
        .padding(.vertical, DumbSpacing.sm)
        .background(CorpPalette.surface.opacity(0.92))
    }

    private var gameHeader: some View {
        DumbCard(accent: CorpPalette.courtroomNavy, isSelected: hasBingo) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(CorpPalette.courtroomNavy.opacity(0.14), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(marked.count) / 9)
                        .stroke(
                            CorpPalette.courtroomNavy,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(marked.count)")
                        .font(.system(.title2, design: .rounded).weight(.black))
                        .foregroundStyle(CorpPalette.courtroomNavy)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 5) {
                    DumbStatusPill(
                        hasBingo ? "MOTION CARRIED" : "LIVE MEETING",
                        systemImage: hasBingo ? "checkmark.seal.fill" : "video.fill",
                        accent: CorpPalette.courtroomNavy
                    )
                    Text(hasBingo ? "You have achieved corporate escape velocity." : "Mark the phrases as they happen.")
                        .font(.headline.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                        .contentTransition(.opacity)
                    Text("\(completedGames) completed game\(completedGames == 1 ? "" : "s")")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("completedBingoCount")
                        .accessibilityValue("\(completedGames)")
                }
            }
        }
    }

    private func squareButton(index: Int) -> some View {
        let isFree = board[index] == "FREE SPACE"
        let isMarked = marked.contains(index)
        return Button {
            guard !isFree else { return }
            toggle(index)
        } label: {
            VStack(spacing: 7) {
                Image(systemName: isMarked ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.black))
                    .foregroundStyle(isMarked ? CorpPalette.actionInk : CorpPalette.courtroomNavy)
                    .accessibilityHidden(true)
                Text(board[index])
                    .font(.system(.subheadline, design: .rounded).weight(.black))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.78)
                    .lineLimit(3)
                    .foregroundStyle(isMarked ? CorpPalette.actionInk : CorpPalette.ink)
            }
            .frame(maxWidth: .infinity, minHeight: 98)
            .padding(8)
            .background(isMarked ? CorpPalette.courtroomNavy : CorpPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CorpPalette.courtroomNavy.opacity(isMarked ? 0 : 0.15), lineWidth: 2)
                if hasBingo && winningLineIndices.contains(index) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(CorpPalette.sunshine, lineWidth: 4)
                }
            }
        }
        .buttonStyle(DumbPressStyle())
        .accessibilityLabel(board[index])
        .accessibilityValue(isFree ? "Free space, already marked" : (isMarked ? "Marked" : "Unmarked"))
        .accessibilityIdentifier("bingoSquare_\(index)")
    }

    private var hasBingo: Bool {
        !winningLineIndices.isEmpty
    }

    private let bingoLines = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]

    private func updateWinningLine() {
        winningLineIndices = bingoLines.first { $0.allSatisfy(marked.contains) } ?? []
    }

    private var resultText: String {
        if hasBingo {
            return "BINGO. You may now stare into the middle distance."
        }
        return "\(marked.count) cliché(s) detected. Remain alert."
    }

    private func restoreGame() {
        guard board.isEmpty else { return }
        if
            let boardData = UserDefaults.standard.string(forKey: Self.boardKey)?.data(using: .utf8),
            let savedBoard = try? JSONDecoder().decode([String].self, from: boardData),
            savedBoard.count == 9,
            let markedData = UserDefaults.standard.string(forKey: Self.markedKey)?.data(using: .utf8),
            let savedMarked = try? JSONDecoder().decode([Int].self, from: markedData)
        {
            board = savedBoard
            marked = Set(savedMarked)
            updateWinningLine()
            if hasBingo {
                currentBoardWon = true
            }
        } else {
            newGame()
        }
    }

    private func newGame() {
        let selected = Array(phrasePool.shuffled().prefix(8))
        board = Array(selected.prefix(4)) + ["FREE SPACE"] + Array(selected.dropFirst(4))
        marked = [4]
        winningLineIndices = []
        currentBoardWon = false
        gameRevision += 1
        persistGame()
    }

    private func toggle(_ index: Int) {
        withAnimation(reduceMotion ? nil : DumbMotion.quick) {
            if marked.contains(index) {
                marked.remove(index)
            } else {
                marked.insert(index)
            }
            if hasBingo, !currentBoardWon {
                completedGames += 1
                currentBoardWon = true
            }
            updateWinningLine()
            persistGame()
        }
    }

    private func eraseAllData() {
        completedGames = 0
        newGame()
    }

    private func persistGame() {
        guard
            let boardData = try? JSONEncoder().encode(board),
            let markedData = try? JSONEncoder().encode(Array(marked).sorted())
        else { return }
        UserDefaults.standard.set(String(data: boardData, encoding: .utf8), forKey: Self.boardKey)
        UserDefaults.standard.set(String(data: markedData, encoding: .utf8), forKey: Self.markedKey)
    }
}
