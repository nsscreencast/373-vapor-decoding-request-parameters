import Vapor
import FluentPostgreSQL

final class ProjectsController : RouteCollection {
    func boot(router: Router) throws {
        router.get(use: index)
        router.get(Project.parameter, use: show)
        router.post(ProjectContent.self, use: create)        
        router.put(ProjectContent.self, at: Project.parameter, use: update)
        router.delete(Project.parameter, use: delete)
    }
    
    private func index(_ req: Request) throws -> Future<[Project]> {
        return Project.query(on: req)
            .sort(\.createdAt, .descending)
            .all()
    }
    
    private func show(_ req: Request) throws -> Future<Project> {
        return try req.parameters.next(Project.self)
    }
    
    private func create(_ req: Request, _ projectContent: ProjectContent) throws -> Future<Project> {
        return projectContent.buildProject().save(on: req)
    }
    
    private func update(_ req: Request, _ projectContent: ProjectContent) throws -> Future<Project> {
        return try req.parameters.next(Project.self)
            .flatMap { project in
                project.title = projectContent.title ?? project.title
                project.description = projectContent.description ?? project.description
                
                return project.update(on: req)
        }
    }
    
    private func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Project.self)
            .flatMap { project in
                return project.delete(on: req).transform(to: .noContent)
        }
    }
    
    struct ProjectContent : Content {
        var title: String?
        var description: String?
        
        func buildProject() -> Project {
            return Project(title: title ?? "<untitled>", description: description ?? "")
        }
    }
}
