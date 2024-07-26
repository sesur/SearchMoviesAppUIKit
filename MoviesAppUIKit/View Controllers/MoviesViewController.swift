import UIKit
import SwiftUI
import Combine

class MoviesViewController: UIViewController {
    private let viewModel: MovieListViewModel
    var cancellable: Set<AnyCancellable> = []
    
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var moviesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.$isLodingCompleted
            .sink { [weak self] completed in
                if completed {
                    // reload the tableview
                    self?.moviesTableView.reloadData()
                }
            }
            .store(in: &cancellable)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Register cells
        moviesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
        
        // Initialize stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add stack view to the view hierarchy
        view.addSubview(stackView)
        
        // Add searchBar and moviesTableView to the stack view
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(moviesTableView)
        
        // Set stack view constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moview = viewModel.movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = moview.title
        cell.contentConfiguration = content
        return cell
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setSearchText(searchText)
    }
}

struct MoviesViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MoviesViewController
    
    func updateUIViewController(_ uiViewController: MoviesViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> MoviesViewController {
        MoviesViewController(viewModel: MovieListViewModel(httpClient: HTTPClient()))
    }
}

#Preview {
    MoviesViewControllerRepresentable()
}
