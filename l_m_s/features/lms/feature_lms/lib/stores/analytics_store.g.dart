// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AnalyticsStore on _AnalyticsStore, Store {
  Computed<double>? _$averageScoreComputed;

  @override
  double get averageScore =>
      (_$averageScoreComputed ??= Computed<double>(() => super.averageScore,
              name: '_AnalyticsStore.averageScore'))
          .value;
  Computed<int>? _$testsTakenComputed;

  @override
  int get testsTaken =>
      (_$testsTakenComputed ??= Computed<int>(() => super.testsTaken,
              name: '_AnalyticsStore.testsTaken'))
          .value;
  Computed<double>? _$passRateComputed;

  @override
  double get passRate =>
      (_$passRateComputed ??= Computed<double>(() => super.passRate,
              name: '_AnalyticsStore.passRate'))
          .value;
  Computed<List<double>>? _$recentScoresComputed;

  @override
  List<double> get recentScores => (_$recentScoresComputed ??=
          Computed<List<double>>(() => super.recentScores,
              name: '_AnalyticsStore.recentScores'))
      .value;
  Computed<List<Map<String, dynamic>>>? _$perQuestionBreakdownComputed;

  @override
  List<Map<String, dynamic>> get perQuestionBreakdown =>
      (_$perQuestionBreakdownComputed ??= Computed<List<Map<String, dynamic>>>(
              () => super.perQuestionBreakdown,
              name: '_AnalyticsStore.perQuestionBreakdown'))
          .value;
  Computed<Map<String, double>>? _$accuracyByQuestionTypeComputed;

  @override
  Map<String, double> get accuracyByQuestionType =>
      (_$accuracyByQuestionTypeComputed ??= Computed<Map<String, double>>(
              () => super.accuracyByQuestionType,
              name: '_AnalyticsStore.accuracyByQuestionType'))
          .value;
  Computed<List<Map<String, dynamic>>>? _$weakTopicsComputed;

  @override
  List<Map<String, dynamic>> get weakTopics => (_$weakTopicsComputed ??=
          Computed<List<Map<String, dynamic>>>(() => super.weakTopics,
              name: '_AnalyticsStore.weakTopics'))
      .value;

  late final _$loadingAtom =
      Atom(name: '_AnalyticsStore.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_AnalyticsStore.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$testAttemptsAtom =
      Atom(name: '_AnalyticsStore.testAttempts', context: context);

  @override
  ObservableList<TestAttempt> get testAttempts {
    _$testAttemptsAtom.reportRead();
    return super.testAttempts;
  }

  @override
  set testAttempts(ObservableList<TestAttempt> value) {
    _$testAttemptsAtom.reportWrite(value, super.testAttempts, () {
      super.testAttempts = value;
    });
  }

  late final _$loadTestAttemptsForStudentAsyncAction = AsyncAction(
      '_AnalyticsStore.loadTestAttemptsForStudent',
      context: context);

  @override
  Future<void> loadTestAttemptsForStudent(String studentId) {
    return _$loadTestAttemptsForStudentAsyncAction
        .run(() => super.loadTestAttemptsForStudent(studentId));
  }

  late final _$loadTestAttemptsForAnalyticsAsyncAction = AsyncAction(
      '_AnalyticsStore.loadTestAttemptsForAnalytics',
      context: context);

  @override
  Future<void> loadTestAttemptsForAnalytics() {
    return _$loadTestAttemptsForAnalyticsAsyncAction
        .run(() => super.loadTestAttemptsForAnalytics());
  }

  late final _$_AnalyticsStoreActionController =
      ActionController(name: '_AnalyticsStore', context: context);

  @override
  void clear() {
    final _$actionInfo = _$_AnalyticsStoreActionController.startAction(
        name: '_AnalyticsStore.clear');
    try {
      return super.clear();
    } finally {
      _$_AnalyticsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
testAttempts: ${testAttempts},
averageScore: ${averageScore},
testsTaken: ${testsTaken},
passRate: ${passRate},
recentScores: ${recentScores},
perQuestionBreakdown: ${perQuestionBreakdown},
accuracyByQuestionType: ${accuracyByQuestionType},
weakTopics: ${weakTopics}
    ''';
  }
}
