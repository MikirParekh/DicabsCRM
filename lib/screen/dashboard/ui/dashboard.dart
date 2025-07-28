import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/logout/logout.dart';
import 'package:flutter/material.dart';
import 'package:dicabs/SharedPreference.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import '../../mainpage/ui/main_page.dart';
import '../model/dashboard_Model.dart';

class Dashboard extends StatefulWidget {
  final String userCode;
  final String salesCode;

  const Dashboard({
    super.key,
    required this.userCode,
    required this.salesCode,
  });

  @override
  State<Dashboard> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<Dashboard> {
  // late Future<List<DashboardModel>> _dashboardData;
  final MainPageRepository _repository = MainPageRepository();

  List<DashboardModel> originalData = [];
  List<DashboardModel> filteredData = [];
  String? selectedSubject;
  String? selectedCategory;
  String? selectedStatus;
  String? selectedSalesPerson;
  String? selectedDate;
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    String? userCode = await StorageManager.readData('userCode');
    String? salesCode = await StorageManager.readData('salesCode');

    if (userCode != null && salesCode != null) {
      final data = await _repository.fetchDeshboard(userCode, salesCode);
      setState(() {
        originalData = data;
        filteredData = data;
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredData = originalData.where((item) {
        return (item.subject?.toLowerCase().contains(query) ?? false) ||
            (item.category?.toLowerCase().contains(query) ?? false) ||
            (item.taskStatus?.toLowerCase().contains(query) ?? false) ||
            (item.salesPerson?.toLowerCase().contains(query) ?? false) ||
            (item.creationDate?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Widget _buildDropdownFilter(String label, List<String> items, String? value,
  //     Function(String?) onChanged) {
  //   return DropdownButton<String>(
  //     hint: Text(label),
  //     value: value,
  //     onChanged: onChanged,
  //     items: [
  //       const DropdownMenuItem(value: null, child: Text("All")),
  //       ...items
  //           .map((item) => DropdownMenuItem(value: item, child: Text(item)))
  //           .toList(),
  //     ],
  //   );
  // }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LogOutBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700,
          elevation: 3,
          centerTitle: true,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  //MARK: Logout
                  _showLogoutDialog(context);
                  logBlue(msg: "Log Out button pressed");
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ))
          ],
        ),
        body: originalData.isEmpty
            // ? const Center(child: CircularProgressIndicator())
            ? Center(
                child: isLoading != true
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/image/no_image.jpg'),
                          const Text(
                            "No Data Available",
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      )
                    : const CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  applyFilters();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (val) => applyFilters(),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await loadDashboardData();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.subject ?? 'No Subject',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('To', item.to),
                                  _buildInfoRow('Remarks', item.remark),
                                  _buildInfoRow('Regarding', item.regarding),
                                  _buildInfoRow('Category', item.category),
                                  _buildInfoRow('Status', item.taskStatus),
                                  _buildInfoRow(
                                      'Created On', item.creationDate),
                                  _buildInfoRow(
                                      'Sales Person', item.salesPerson),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainPage(
                        userCode: '',
                        salesCode: '',
                      )),
            );
          },
          backgroundColor: Colors.blue.shade700,
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
