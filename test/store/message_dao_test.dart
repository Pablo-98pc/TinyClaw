import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';

void main() {
  late AppDatabase db;
  late MessageDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.messageDao;
  });

  tearDown(() => db.close());

  group('MessageDao', () {
    test('insert and retrieve message', () async {
      await dao.insertMessage(MessagesCompanion.insert(
        role: 'user',
        content: 'Hello TinyClaw',
      ));
      final msgs = await dao.allMessages();
      expect(msgs.length, 1);
      expect(msgs.first.role, 'user');
      expect(msgs.first.content, 'Hello TinyClaw');
      expect(msgs.first.isVoiceInput, false);
    });

    test('messages ordered by timestamp', () async {
      await dao.insertMessage(MessagesCompanion.insert(
        role: 'user', content: 'First',
        timestamp: Value(DateTime(2026, 3, 15, 10, 0)),
      ));
      await dao.insertMessage(MessagesCompanion.insert(
        role: 'assistant', content: 'Second',
        timestamp: Value(DateTime(2026, 3, 15, 10, 1)),
        specialistBadge: const Value('chat'),
      ));
      final msgs = await dao.allMessages();
      expect(msgs.length, 2);
      expect(msgs[0].content, 'First');
      expect(msgs[1].content, 'Second');
      expect(msgs[1].specialistBadge, 'chat');
    });

    test('clearAll removes all messages', () async {
      await dao.insertMessage(MessagesCompanion.insert(role: 'user', content: 'A'));
      await dao.insertMessage(MessagesCompanion.insert(role: 'user', content: 'B'));
      expect(await dao.allMessages(), hasLength(2));
      await dao.clearAll();
      expect(await dao.allMessages(), isEmpty);
    });

    test('watch emits updates', () async {
      final stream = dao.watchAllMessages().asBroadcastStream();
      final emissions = <List<Message>>[];
      final sub = stream.listen(emissions.add);

      // Wait for the initial empty emission
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return emissions.isEmpty;
      });
      expect(emissions.first, hasLength(0));

      await dao.insertMessage(MessagesCompanion.insert(role: 'user', content: 'Watch'));

      // Wait for the second emission with 1 item
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return emissions.length < 2;
      });
      expect(emissions[1], hasLength(1));
      await sub.cancel();
    });
  });
}
