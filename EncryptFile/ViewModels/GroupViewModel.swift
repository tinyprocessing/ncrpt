import Foundation

class GroupViewModel: ObservableObject {
    @Published var selectedGroup = UUID()
    @Published var selectedTeam = UUID()
    @Published var groupData = [GroupData]()
    @Published var isCreateNewGroup = false
    @Published var isShowSettings = false

    init() {
        getMockData()
        selectedGroup = groupData.first?.id ?? UUID()
    }

    private func getMockData() {
        groupData = mockGroupData
    }

    func getNewGroupId() {
        isCreateNewGroup = true
        isShowSettings = false
        selectedGroup = UUID()
    }

    func showSettings() {
        isShowSettings = true
        isCreateNewGroup = false
        selectedGroup = UUID()
    }

    func getTitle() -> String {
        if isShowSettings {
            return "Settings"
        } else if isCreateNewGroup {
            return "Add group"
        } else {
            return groupData.first { $0.id == selectedGroup }?.name ?? ""
        }
    }

    func getTeams() -> [TeamData] {
        return groupData.first { $0.id == selectedGroup }?.teams ?? []
    }
}

// MARK: - default for preview

let mockGroupData = [
    GroupData(name: "First", logo: "secure", accentColor: .blue, teams: mockTeamData),
    GroupData(name: "Second", accentColor: .green),
    GroupData(name: "Third", accentColor: .purple)
]

let mockTeamData = [
    TeamData(name: "FirstGroup", accentColor: .blue),
    TeamData(name: "SecondGroup", accentColor: .green),
    TeamData(name: "ThirdGroup", accentColor: .purple),
    TeamData(name: "FourthGroup", accentColor: .blue),
    TeamData(name: "FifthGroup", accentColor: .yellow)
]
