import Foundation

class APIService {
    static let shared = APIService()
    
    // MARK: - Configuration
    // Production backend on Railway
    private let baseURL = "https://ctf-game-backend-production.up.railway.app/api"
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        // Configure session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        // Configure JSON decoder
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Configure JSON encoder
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Authentication
    
    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        return try await post("/auth/register", body: request)
    }
    
    func login(_ request: LoginRequest) async throws -> AuthResponse {
        return try await post("/auth/login", body: request)
    }
    
    func logout() async throws {
        let _: EmptyResponse = try await post("/auth/logout", body: EmptyRequest())
    }
    
    func deleteAccount() async throws {
        let response: DeleteAccountResponse = try await delete("/account")
        Logger.info("Account deleted: \(response.message)")
    }
    
    func getCurrentUser() async throws -> User {
        let response: CurrentUserResponse = try await get("/auth/me")
        return response.user
    }
    
    // MARK: - Teams
    
    func getTeams() async throws -> [Team] {
        let response: TeamsResponse = try await get("/teams")
        return response.teams
    }
    
    func getTeamStats(teamId: Int) async throws -> TeamStatsResponse {
        return try await get("/teams/\(teamId)/stats")
    }
    
    func joinTeam(teamId: Int) async throws -> Team {
        let response: JoinTeamResponse = try await post("/teams/\(teamId)/join", body: EmptyRequest())
        return response.team
    }
    
    // MARK: - Flags
    
    func getNearbyFlags(latitude: Double, longitude: Double, radius: Double = 2000) async throws -> FlagsResponse {
        let queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)")
        ]
        return try await get("/flags", queryItems: queryItems)
    }
    
    func getFlagDetail(flagId: String) async throws -> FlagDetailResponse {
        return try await get("/flags/\(flagId)")
    }
    
    func captureFlag(flagId: String, latitude: Double, longitude: Double, defenderTypeId: Int?) async throws -> CaptureResponse {
        let request = CaptureRequest(latitude: latitude, longitude: longitude, defenderTypeId: defenderTypeId)
        return try await post("/flags/\(flagId)/capture", body: request)
    }
    
    // MARK: - Defenders
    
    func getDefenderTypes() async throws -> [DefenderType] {
        let response: DefenderTypesResponse = try await get("/defender-types")
        return response.defenderTypes
    }
    
    // MARK: - Leaderboard
    
    func getGlobalLeaderboard(limit: Int = 100, offset: Int = 0) async throws -> LeaderboardResponse {
        let queryItems = [
            URLQueryItem(name: "type", value: "global"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        return try await get("/leaderboard", queryItems: queryItems)
    }
    
    func getTeamLeaderboard() async throws -> TeamLeaderboardResponse {
        let queryItems = [URLQueryItem(name: "type", value: "team")]
        return try await get("/leaderboard", queryItems: queryItems)
    }
    
    func getMyRank() async throws -> LeaderboardEntry {
        let response: MyRankResponse = try await get("/leaderboard/me")
        return response.user
    }
    
    // MARK: - HTTP Methods
    
    private func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + path)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addHeaders(to: &request)
        
        return try await performRequest(request)
    }
    
    private func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(body)
        addHeaders(to: &request)
        
        return try await performRequest(request)
    }
    
    private func delete<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        addHeaders(to: &request)
        
        return try await performRequest(request)
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        Logger.debug("API Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        Logger.debug("API Response: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            Logger.error("Decoding error: \(error)")
            Logger.debug("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    private func addHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = KeychainService.shared.load(for: .authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

// MARK: - Helper Types

struct EmptyRequest: Codable {}
struct EmptyResponse: Codable {}

struct CurrentUserResponse: Codable {
    let user: User
}

struct TeamsResponse: Codable {
    let teams: [Team]
}

struct JoinTeamResponse: Codable {
    let message: String
    let team: Team
}

struct MyRankResponse: Codable {
    let user: LeaderboardEntry
}

struct DeleteAccountResponse: Codable {
    let message: String
}

struct ErrorResponse: Codable {
    let message: String
    let error: String?
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError(Error)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return message
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please login again."
        }
    }
}
