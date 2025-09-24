import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter/material.dart';

class TaskMemberBottomView extends StatefulWidget {
  final Function(List<String>) onTaskMemberSelected;

  const TaskMemberBottomView({super.key, required this.onTaskMemberSelected});

  @override
  State<TaskMemberBottomView> createState() => _TaskMemberBottomViewState();
}

class _TaskMemberBottomViewState extends State<TaskMemberBottomView> {
  final MainPageRepository repository = MainPageRepository();
  final TextEditingController _searchController = TextEditingController();

  List<String> _allTaskMembers = [];
  List<String> _filteredTaskMembers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Set<String> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    _loadTaskMembers();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadTaskMembers() async {
    try {
      final data = await repository.fetchTaskMember();
      setState(() {
        _allTaskMembers = data;
        _filteredTaskMembers = data;
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
      _filteredTaskMembers = _allTaskMembers
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSelection() {
    widget.onTaskMemberSelected(_selectedMembers.toList());
    Navigator.pop(context);
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
                  'Select TaskMember',
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
                  hintText: 'Search task members...',
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
                        : _filteredTaskMembers.isEmpty
                            ? const Center(child: Text('No task member found.'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _filteredTaskMembers.length,
                                itemBuilder: (context, index) {
                                  final member = _filteredTaskMembers[index];
                                  final isSelected =
                                      _selectedMembers.contains(member);
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedMembers.add(member);
                                          } else {
                                            _selectedMembers.remove(member);
                                          }
                                        });
                                      },
                                      title: Text(
                                        member,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  );
                                },
                              ),
              ),
              if (_selectedMembers.isNotEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Select",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: _submitSelection,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                )
            ],
          ),
        );
      },
    );
  }
}
