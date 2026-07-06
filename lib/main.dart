import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Titbits Bistro Point',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C4B3E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      debugShowCheckedModeBanner: false,
      home: const TitbitsBistroPoint(),
    );
  }
}

class TitbitsBistroPoint extends StatefulWidget {
  const TitbitsBistroPoint({super.key});

  @override
  State<TitbitsBistroPoint> createState() => _TitbitsBistroPointState();
}

class _TitbitsBistroPointState extends State<TitbitsBistroPoint> {
  int _selectedIndex = 0;
  final List<DailySalesEntry> _salesEntries = [];
  final List<ExpenseEntry> _expenseEntries = [];

  // Daily Sales Controllers
  final TextEditingController _quantityController = TextEditingController();
  DateTime _selectedSalesDate = DateTime.now();
  String? _selectedDepartment;
  String? _selectedMenuItem;

  // Expense Controllers
  final TextEditingController _fixedChargeController =
      TextEditingController(text: '560');
  final TextEditingController _extraExpenseRemarkController =
      TextEditingController();
  final TextEditingController _extraExpenseAmountController =
      TextEditingController();
  DateTime _selectedExpenseDate = DateTime.now();

  final List<String> _departments = ['OPD', 'MOT', 'TML'];
  final List<String> _menuItems = [
    'CAPPUCHINO',
    'LATTE',
    'ESPRESSO',
    '2 ESPRESSO',
    'AMRICANO',
    'FLAT WHITE',
    'MACHIATO',
    'LATTE MACHIATO',
    'AMRICANO WITH MILK',
    'MILK TEA',
    'PRIMIX TEA'
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _fixedChargeController.dispose();
    _extraExpenseRemarkController.dispose();
    _extraExpenseAmountController.dispose();
    super.dispose();
  }

  void _addSalesEntry() {
    if (_selectedDepartment == null ||
        _selectedMenuItem == null ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields before adding.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _salesEntries.add(
        DailySalesEntry(
          date: _selectedSalesDate,
          department: _selectedDepartment!,
          menuItem: _selectedMenuItem!,
          quantity: quantity,
        ),
      );
      _selectedDepartment = null;
      _selectedMenuItem = null;
      _quantityController.clear();
    });
  }

  void _deleteSalesEntry(int index) {
    setState(() {
      _salesEntries.removeAt(index);
    });
  }

  void _addExpenseEntry() {
    if (_extraExpenseRemarkController.text.isEmpty ||
        _extraExpenseAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all expense fields.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final fixedCharge = int.tryParse(_fixedChargeController.text) ?? 560;
    final extraExpense =
        int.tryParse(_extraExpenseAmountController.text) ?? 0;

    if (extraExpense < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Extra expense cannot be negative.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _expenseEntries.add(
        ExpenseEntry(
          date: _selectedExpenseDate,
          fixedCharge: fixedCharge,
          extraExpenseRemark: _extraExpenseRemarkController.text,
          extraExpense: extraExpense,
        ),
      );
      _extraExpenseRemarkController.clear();
      _extraExpenseAmountController.clear();
    });
  }

  void _deleteExpenseEntry(int index) {
    setState(() {
      _expenseEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Titbits Bistro Point',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDailySalesTab(),
          _buildExpensesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Daily Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Expenses',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }

  Widget _buildDailySalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Sales Entry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(_selectedSalesDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedSalesDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _selectedSalesDate = date);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  // Department Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    value: _selectedDepartment,
                    items: _departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDepartment = value),
                  ),
                  const SizedBox(height: 16),
                  // Menu Item Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Menu Item',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    value: _selectedMenuItem,
                    items: _menuItems.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedMenuItem = value),
                  ),
                  const SizedBox(height: 16),
                  // Quantity
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity Sold',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'Enter number',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addSalesEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Sales Entry'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_salesEntries.isNotEmpty) ...[
            const Text(
              'Today\'s Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._salesEntries.map((entry) {
              final index = _salesEntries.indexOf(entry);
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      entry.quantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(entry.menuItem),
                  subtitle: Text(
                    '${entry.department} • ${DateFormat('dd MMM').format(entry.date)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSalesEntry(index),
                    tooltip: 'Delete entry',
                  ),
                ),
              );
            }),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No sales entries yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Expense / Overhead',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(_selectedExpenseDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedExpenseDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _selectedExpenseDate = date);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  // Fixed Charge
                  TextField(
                    controller: _fixedChargeController,
                    decoration: const InputDecoration(
                      labelText: 'Fixed Charge (RS)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'e.g., 560',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Extra Expense Remark
                  TextField(
                    controller: _extraExpenseRemarkController,
                    decoration: const InputDecoration(
                      labelText: 'Extra Expense Remark',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'e.g., Repair, Extra Milk packet',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Extra Expense Amount
                  TextField(
                    controller: _extraExpenseAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Extra Expense (RS)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'Enter amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addExpenseEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense Entry'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_expenseEntries.isNotEmpty) ...[
            const Text(
              'Expense History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._expenseEntries.map((entry) {
              final index = _expenseEntries.indexOf(entry);
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    child: Text(
                      '₹${entry.extraExpense}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  title: Text(entry.extraExpenseRemark),
                  subtitle: Text(
                    '${DateFormat('dd MMM yyyy').format(entry.date)} • Fixed: ₹${entry.fixedCharge}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExpenseEntry(index),
                    tooltip: 'Delete expense',
                  ),
                ),
              );
            }),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.money_off_csred,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses recorded',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Data Models
class DailySalesEntry {
  final DateTime date;
  final String department;
  final String menuItem;
  final int quantity;

  DailySalesEntry({
    required this.date,
    required this.department,
    required this.menuItem,
    required this.quantity,
  });
}

class ExpenseEntry {
  final DateTime date;
  final int fixedCharge;
  final String extraExpenseRemark;
  final int extraExpense;

  ExpenseEntry({
    required this.date,
    required this.fixedCharge,
    required this.extraExpenseRemark,
    required this.extraExpense,
  });
}
