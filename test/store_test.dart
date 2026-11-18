import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:recitro/data/recitro_store.dart';
import 'package:recitro/models/call_outcome.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  test('ledger keeps points after session deleted', () async {
    final store = RecitroStore();
    await store.addStudent('Ada');
    await store.addSession(
      name: 'Quiz',
      pointsPerAnswer: 5,
      rewardLabel: 'Star',
      allowRecallUnanswered: false,
      allowRecallAnswered: false,
    );
    final session = store.sessions.first;
    final studentId = store.students.first.id;
    await store.pickRandomStudent(session);
    await store.markAnswered(store.sessionById(session.id)!);
    await store.claimReward(store.sessionById(session.id)!, studentId);

    expect(store.totalPointsForStudent(studentId), 5);
    await store.deleteSession(session.id);
    expect(store.totalPointsForStudent(studentId), 5);
    expect(store.sessions, isEmpty);
  });

  test('answered without claim has no ledger points', () async {
    final store = RecitroStore();
    await store.addStudent('Bo');
    await store.addSession(
      name: 'Drill',
      pointsPerAnswer: 3,
      rewardLabel: 'Badge',
      allowRecallUnanswered: true,
      allowRecallAnswered: false,
    );
    final session = store.sessions.first;
    final studentId = store.students.first.id;
    await store.pickRandomStudent(session);
    await store.markAnswered(store.sessionById(session.id)!);

    expect(store.totalPointsForStudent(studentId), 0);
    final state = session.studentStates[studentId];
    expect(state?.outcome, CallOutcome.answered);
    expect(state?.rewardClaimed, false);
  });

  test('answered recall uses lower pick weight', () async {
    final store = RecitroStore();
    await store.addStudent('A');
    await store.addStudent('B');
    await store.addSession(
      name: 'S',
      pointsPerAnswer: 1,
      rewardLabel: 'R',
      allowRecallUnanswered: false,
      allowRecallAnswered: true,
    );
    final session = store.sessions.first;
    final a = store.students[0].id;
    final b = store.students[1].id;

    await store.pickRandomStudent(session);
    await store.markAnswered(store.sessionById(session.id)!);
    await store.claimReward(store.sessionById(session.id)!, a);

    expect(
      store.pickWeightForStudent(store.sessionById(session.id)!, store.students[0]),
      RecitroStore.answeredRecallPickWeight,
    );
    expect(
      store.pickWeightForStudent(store.sessionById(session.id)!, store.students[1]),
      RecitroStore.primaryPickWeight,
    );

    expect(
      store.pickWeightForStudent(store.sessionById(session.id)!, store.studentById(b)!),
      greaterThan(
        store.pickWeightForStudent(store.sessionById(session.id)!, store.studentById(a)!),
      ),
    );
  });
}