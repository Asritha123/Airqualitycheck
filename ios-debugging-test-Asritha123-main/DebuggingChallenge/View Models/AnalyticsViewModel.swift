import Combine

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var analyticsDetails: [AnalyticsDetails] = []
    @Published var recentProjects: [Project] = []
    @Published var isLoading: Bool = false

    let analyticsService: AnalyticsService
    let projectService: ProjectService
    
    init(analyticsService: AnalyticsService, projectService: ProjectService) {
        self.analyticsService = analyticsService
        self.projectService = projectService
    }
    
    func loadAnalytics() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            // Run both calls in parallel
            async let detailsTask = self.analyticsService.fetchAnalyticsDetails()
            async let projectsTask = self.projectService.fetchProjects()
            let (details, projects) = await (detailsTask, projectsTask)

            // Hop to main actor for UI state
            await MainActor.run {
                self.analyticsDetails = details
                self.recentProjects = projects
                self.isLoading = false
            }
        }
    }
}
