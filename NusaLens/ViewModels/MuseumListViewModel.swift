import Foundation

@MainActor
class MuseumListViewModel: ObservableObject {
    @Published var searchText = ""
    
    func filteredMuseums(from museums: [Museum]) -> [Museum] {
        if searchText.isEmpty {
            return museums
        }
        return museums.filter { museum in
            museum.name.localizedCaseInsensitiveContains(searchText) ||
            museum.province.localizedCaseInsensitiveContains(searchText) ||
            museum.region.localizedCaseInsensitiveContains(searchText)
        }
    }
}
