import 'dart:convert';

import 'package:bb_mobile/_pkg/error.dart';
import 'package:bb_mobile/_pkg/storage/hive.dart';
import 'package:bb_mobile/_pkg/storage/storage.dart';
import 'package:payjoin_flutter/receive.dart';
import 'package:payjoin_flutter/send.dart';

class PayjoinSessionStorage {
  PayjoinSessionStorage({required HiveStorage hiveStorage})
      : _hiveStorage = hiveStorage;

  final HiveStorage _hiveStorage;

  Future<Err?> insertReceiverSession(Receiver receiver) async {
    try {
      final receiver_id = receiver.id();
      final (pjSessions, err) =
          await _hiveStorage.getValue(StorageKeys.payjoin);
      if (err != null) {
        // no sessions exist. initialize the indices
        final jsn = jsonEncode({
          'recv_sessions': [receiver_id],
          'send_sessions': [],
        });
        await _hiveStorage.saveValue(
          key: StorageKeys.payjoin,
          value: jsn,
        );
      } else {
        // found existing sessions. insert the session ID
        final sessions = jsonDecode(pjSessions!);
        final recv_sessions = sessions['recv_sessions'] as List<dynamic>;
        final send_sessions = sessions['send_sessions'] as List<dynamic>;
        recv_sessions.add(receiver_id);
        final jsn = jsonEncode({
          'recv_sessions': recv_sessions,
          'send_sessions': send_sessions,
        });
        await _hiveStorage.saveValue(
          key: StorageKeys.payjoin,
          value: jsn,
        );
      }
      // insert the receiver data
      await _hiveStorage.saveValue(
        key: receiver_id,
        value: jsonEncode(receiver.toJson()),
      );
      return null;
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<(Receiver?, Err?)> readReceiverSession(
    String sessionId,
  ) async {
    try {
      final (jsn, err) = await _hiveStorage.getValue(sessionId);
      if (err != null) throw err;
      final obj = jsonDecode(jsn!) as String;
      print(obj);
      final session = Receiver.fromJson(obj);
      return (session, null);
    } catch (e) {
      return (
        null,
        Err(
          e.toString(),
          expected: e.toString() == 'No Receiver with id $sessionId',
        )
      );
    }
  }

  // impl readAllReceivers
  Future<(List<Receiver>, Err?)> readAllReceivers() async {
    final (jsn, err) = await _hiveStorage.getValue(StorageKeys.payjoin);
    if (err != null) return (List<Receiver>.empty(), err);
    final sessions = jsonDecode(jsn!) as Map<String, dynamic>;
    final recv_sessions = sessions['recv_sessions'] as List<String>;
    final receivers =
        recv_sessions.map((json) => Receiver.fromJson(json)).toList();
    return (receivers, null);
  }

  Future<Err?> insertSenderSession(Sender sender, String pjUri) async {
    try {
      final sender_id = pjUri;
      final (pjSessions, err) =
          await _hiveStorage.getValue(StorageKeys.payjoin);
      if (err != null) {
        // no sessions exist. initialize the indices
        final jsn = jsonEncode({
          'recv_sessions': [],
          'send_sessions': [sender_id],
        });
        await _hiveStorage.saveValue(
          key: StorageKeys.payjoin,
          value: jsn,
        );
      } else {
        // found existing sessions. insert the session ID
        final sessions = jsonDecode(pjSessions!);
        final recv_sessions = sessions['recv_sessions'] as List<dynamic>;
        final send_sessions = sessions['send_sessions'] as List<dynamic>;
        recv_sessions.add(sender_id);
        final jsn = jsonEncode({
          'recv_sessions': recv_sessions,
          'send_sessions': send_sessions,
        });
        await _hiveStorage.saveValue(
          key: StorageKeys.payjoin,
          value: jsn,
        );
      }
      // insert the receiver data
      await _hiveStorage.saveValue(
        key: sender_id,
        value: jsonEncode(sender.toJson()),
      );
      return null;
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<(Sender?, Err?)> readSenderSession(
    String pjUrl,
  ) async {
    try {
      final (jsn, err) = await _hiveStorage.getValue(pjUrl);
      if (err != null) throw err;
      final obj = jsonDecode(jsn!) as String;
      print(obj);
      final session = Sender.fromJson(obj);
      return (session, null);
    } catch (e) {
      return (
        null,
        Err(
          e.toString(),
          expected: e.toString() == 'No Sender with id $pjUrl',
        )
      );
    }
  }

  // impl readAllSenders
  Future<(List<Sender>, Err?)> readAllSenders() async {
    final (jsn, err) = await _hiveStorage.getValue(StorageKeys.payjoin);
    if (err != null) return (List<Sender>.empty(), err);
    final sessions = jsonDecode(jsn!) as Map<String, dynamic>;
    final send_sessions = sessions['send_sessions'] as List<String>;
    final senders = send_sessions.map((json) => Sender.fromJson(json)).toList();
    return (senders, null);
  }
}
