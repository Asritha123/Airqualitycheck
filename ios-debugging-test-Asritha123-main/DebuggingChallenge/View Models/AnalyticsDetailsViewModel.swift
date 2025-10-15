import Combine

@MainActor
final class AnalyticsDetailsViewModel: ObservableObject {
    @Published var recentProjects: [Project] = []
    @Published var isLoading: Bool = false
    let projectService: ProjectService

    init(projectService: ProjectService) {
        self.projectService = projectService
    }

    func loadRecentProjects() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            let projects = await self.projectService.fetchProjects()
            await MainActor.run {
                self.recentProjects = projects
                self.isLoading = false
            }
        }
    }
}
