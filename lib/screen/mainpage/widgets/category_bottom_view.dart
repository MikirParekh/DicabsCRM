import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter/material.dart';

class CategoryBottomView extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryBottomView({super.key, required this.onCategorySelected});

  @override
  State<CategoryBottomView> createState() => _CategoryBottomViewState();
}

class _CategoryBottomViewState extends State<CategoryBottomView> {
  final MainPageRepository repository = MainPageRepository();
  final TextEditingController _searchController = TextEditingController();

  List<String> _allCategories = [];
  List<String> _filteredCategories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadCategories() async {
    try {
      final categories = await repository.fetchCategories();
      setState(() {
        _allCategories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where((cat) => cat.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _filteredCategories.isEmpty
                    ? const Center(child: Text('No categories found.'))
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          _filteredCategories[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          widget.onCategorySelected(_filteredCategories[index]);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

