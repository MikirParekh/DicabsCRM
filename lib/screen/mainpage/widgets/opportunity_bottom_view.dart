import 'package:dicabs/screen/mainpage/model/contact_Model.dart';
import 'package:dicabs/screen/mainpage/model/opportunity_Model.dart'
    as opp_data;
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter/material.dart';

class OpportunityBottomView extends StatefulWidget {
  final Function(String) onOpportunitySelected;

  const OpportunityBottomView({super.key, required this.onOpportunitySelected});

  @override
  State<OpportunityBottomView> createState() => _OpportunityBottomViewState();
}

class _OpportunityBottomViewState extends State<OpportunityBottomView> {
  final MainPageRepository repository = MainPageRepository();
  final TextEditingController _searchController = TextEditingController();

  List<opp_data.Data> _allOpportunities = [];
  List<opp_data.Data> _filteredOpportunities = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadOpportunities() async {
    try {
      final data = await repository.fetchOpportunity();
      setState(() {
        _allOpportunities = data.data ?? [];
        _filteredOpportunities = data.data ?? [];
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
      _filteredOpportunities = _allOpportunities
          .where((item) => item.no!.toLowerCase().contains(query))
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
                  'Select Opportunity',
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
                  hintText: 'Search opportunity no...',
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
                        : _filteredOpportunities.isEmpty
                            ? const Center(child: Text('No opportunity found.'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _filteredOpportunities.length,
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
                                        _filteredOpportunities[index]
                                                .searchName ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _filteredOpportunities[index].no ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        widget.onOpportunitySelected(
                                            _filteredOpportunities[index]
                                                .toString());
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
