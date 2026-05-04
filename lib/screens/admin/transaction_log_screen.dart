import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaction_service.dart';

class TransactionLogScreen extends StatefulWidget {
  const TransactionLogScreen({super.key});

  @override
  State<TransactionLogScreen> createState() => _TransactionLogScreenState();
}

class _TransactionLogScreenState extends State<TransactionLogScreen> {
  final TransactionService _transactionService = TransactionService();
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final token = context.read<AuthProvider>().token!;
    final logs = await _transactionService.getTransactionLogs(token);
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Transaction Log', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _logs.isEmpty
              ? const Center(child: Text('Belum ada transaksi', style: TextStyle(color: Colors.white54)))
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final trx = log['Transaction'];
                      final user = trx?['User'];
                      final details = trx?['TransactionDetails'] as List? ?? [];
                      final isSuccess = log['status'] == 'success';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A4A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSuccess ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Trx #${trx?['transaction_id']}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSuccess ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    log['status'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: isSuccess ? Colors.green : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // User info
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.white38, size: 14),
                                const SizedBox(width: 4),
                                Text(user?['username'] ?? '-', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(width: 8),
                                const Icon(Icons.email, color: Colors.white38, size: 14),
                                const SizedBox(width: 4),
                                Text(user?['email'] ?? '-', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Items
                            ...details.map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.shield, color: Color(0xFFFFD700), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${d['Weapon']?['weapon_name']} x${d['quantity']}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Rp ${d['price']}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                            )),

                            const Divider(color: Colors.white12),

                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                Text(
                                  'Rp ${trx?['total_price']}',
                                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            // Date
                            const SizedBox(height: 4),
                            Text(
                              log['created_at'] ?? '',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}