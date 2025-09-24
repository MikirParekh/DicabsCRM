import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:dicabs/screen/mainpage/widgets/add_contact_bottom_view.dart';
import 'package:flutter/material.dart';

class ContactBottomView extends StatefulWidget {
  final Function(String) onContactSelected;

  const ContactBottomView({super.key, required this.onContactSelected});

  @override
  State<ContactBottomView> createState() => _ContactBottomViewState();
}

class _ContactBottomViewState extends State<ContactBottomView> {
  final MainPageRepository repository = MainPageRepository();
  final TextEditingController _searchController = TextEditingController();

  List<String> _allContacts = [];
  List<String> _filteredContacts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadContacts() async {
    try {
      final contacts = await repository.fetchContactDetails();
      showLog(msg: "Contact list ----> $contacts");
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
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
      _filteredContacts = _allContacts
          .where((contact) => contact.toLowerCase().contains(query))
          .toList();
    });
  }

  void _openAddContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
                onTap: () {
                  showLog(msg: "Bottomsheet : Add Contact");
                },
                child: const AddContactBottomView()),
          ),
        );
      },
    );
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
              Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openAddContactBottomSheet(),
                    icon: const Row(
                      children: [
                        Icon(Icons.add),
                        Text("Add",
                            style: TextStyle(
                              fontSize: 16,
                            ))
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () => _loadContacts(),
                      icon: const Icon(Icons.refresh)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
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
                        : _filteredContacts.isEmpty
                            ? const Center(child: Text('No contacts found.'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _filteredContacts.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        _filteredContacts[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        widget.onContactSelected(
                                            _filteredContacts[index]);
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
