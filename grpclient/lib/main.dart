import 'package:flutter/material.dart';
import 'gRPCService.dart';
import 'src/generated/CompteService.pb.dart';

void main() {
  runApp(BankingApp());
}

class BankingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: AccountDashboard(),
    );
  }
}

class AccountDashboard extends StatefulWidget {
  @override
  _AccountDashboardState createState() => _AccountDashboardState();
}

class _AccountDashboardState extends State<AccountDashboard> {
  final GrpcService grpcService = GrpcService();
  late Future<List<Compte>> accountList;
  late Future<GetTotalSoldeResponse> totalSolde;

  final TextEditingController idController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  TypeCompte selectedType = TypeCompte.COURANT;

  @override
  void initState() {
    super.initState();
    grpcService.createChannel().then((_) {
      refreshAccounts();
      totalSolde = grpcService.getTotalSolde();
    });
  }

  void refreshAccounts() {
    setState(() {
      accountList = grpcService.getAllComptes();
    });
  }

  @override
  void dispose() {
    grpcService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banking Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildAccountList()),
            Divider(),
            _buildAddAccount(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(
          child: FutureBuilder<List<Compte>>(
            future: accountList,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              if (snapshot.data!.isEmpty) return Center(child: Text('No accounts found.'));
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final account = snapshot.data![index];
                  return Card(
                    child: ListTile(
                      title: Text('ID: ${account.id}'),
                      subtitle: Text(
                        'Balance: ${account.solde} | Type: ${account.type.toString().split('.').last}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          grpcService.deleteCompte(account.id).then((message) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                            refreshAccounts();
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: balanceController,
                decoration: InputDecoration(labelText: 'Balance'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 8),
            DropdownButton<TypeCompte>(
              value: selectedType,
              onChanged: (TypeCompte? value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: TypeCompte.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            if (balanceController.text.isEmpty) return;
            final newAccount = CompteRequest()
              ..solde = double.parse(balanceController.text)
              ..type = selectedType;
            grpcService.saveCompte(newAccount).then((_) {
              refreshAccounts();
              balanceController.clear();
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
