import 'package:grpc/grpc.dart';
import 'src/generated/CompteService.pb.dart';
import 'src/generated/CompteService.pbgrpc.dart';

class GrpcService {
  late ClientChannel channel;
  late CompteServiceClient stub;

  Future<void> createChannel() async {
    String host = '10.0.2.2';
    int port = 9090;

    channel = ClientChannel(
      host,
      port: port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = CompteServiceClient(channel);
  }

  Future<List<Compte>> getAllComptes() async {
    final response = await stub.allComptes(GetAllComptesRequest());
    return response.comptes;
  }

  Future<Compte> getCompteById(int id) async {
    final response = await stub.compteById(GetCompteByIdRequest()..id = id);
    return response.compte;
  }

  Future<GetTotalSoldeResponse> getTotalSolde() async {
    return await stub.getTotalSolde(GetTotalSoldeRequest());
  }

  Future<Compte> saveCompte(CompteRequest compteRequest) async {
    final response = await stub.saveCompte(SaveCompteRequest()..compte = compteRequest);
    return response.compte;
  }

  Future<String> deleteCompte(int id) async {
    final response = await stub.deleteCompte(DeleteCompteRequest()..id = id);
    return response.message;
  }

  Future<List<Compte>> getComptesByType(TypeCompte type) async {
    final response = await stub.getComptesByType(GetComptesByTypeRequest()..type = type);
    return response.comptes;
  }

  Future<void> close() async {
    await channel.shutdown();
  }
}
