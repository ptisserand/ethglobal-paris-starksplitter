import 'dart:math';

import 'package:secure_store/secure_store.dart' as ss;
import 'package:starknet/starknet.dart' as s;
import 'package:wallet_kit/wallet_state/index.dart';
import 'package:xmtp/xmtp.dart' as xmtp;
import 'package:web3dart/credentials.dart' as web3;

Future<String> sendTick({
  required Account account,
  required String password,
}) async {
  final privateKey = await ss.PasswordStore()
      .getPrivateKey(id: account.id.toString(), password: password);
  if (privateKey == null) {
    throw Exception("Private key is null");
  }
  var bob = "0xf722B3d620E231FCcD7d3de2719A8DBc0412e095";

  s.Signer? signer = s.Signer(privateKey: s.Felt.fromBytes(privateKey));
  var credentials = web3.EthPrivateKey.fromHex(signer.privateKey.toJson());
  var api = xmtp.Api.create();
  var client = await xmtp.Client.createFromWallet(api, credentials.asSigner());

  var convo = await client.newConversation(bob);
  await client.sendMessage(convo, 'From Starknet!');

/*
  final contract = Counter(
    account: callerAccount,
    address: counterAddress,
  );
  final txHash = await contract.tick();
  print(txHash);
  */
  const txHash = "0xDEADBEEFCACA";
  // set signer to null to avoid storing the private key in memory
  signer = null;

  return txHash;
}
