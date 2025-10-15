import Combine

@MainActor
final class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    let projectService: ProjectService

    init(projectService: ProjectService) {
        self.projectService = projectService
    }

    func loadProjects() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            let fetchedProjects = await self.projectService.fetchProjects()
            await MainActor.run {
                self.projects = fetchedProjects
                self.isLoading = false
            }
        }
    }
}
