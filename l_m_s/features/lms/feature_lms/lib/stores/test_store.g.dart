// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TestStore on _TestStore, Store {
  Computed<int>? _$totalQuestionsComputed;

  @override
  int get totalQuestions =>
      (_$totalQuestionsComputed ??= Computed<int>(() => super.totalQuestions,
              name: '_TestStore.totalQuestions'))
          .value;

  late final _$loadingAtom = Atom(name: '_TestStore.loading', context: context);

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

  late final _$errorAtom = Atom(name: '_TestStore.error', context: context);

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

  late final _$currentAssessmentAtom =
      Atom(name: '_TestStore.currentAssessment', context: context);

  @override
  Assessment? get currentAssessment {
    _$currentAssessmentAtom.reportRead();
    return super.currentAssessment;
  }

  @override
  set currentAssessment(Assessment? value) {
    _$currentAssessmentAtom.reportWrite(value, super.currentAssessment, () {
      super.currentAssessment = value;
    });
  }

  late final _$currentIndexAtom =
      Atom(name: '_TestStore.currentIndex', context: context);

  @override
  int get currentIndex {
    _$currentIndexAtom.reportRead();
    return super.currentIndex;
  }

  @override
  set currentIndex(int value) {
    _$currentIndexAtom.reportWrite(value, super.currentIndex, () {
      super.currentIndex = value;
    });
  }

  late final _$answersAtom = Atom(name: '_TestStore.answers', context: context);

  @override
  ObservableMap<int, String> get answers {
    _$answersAtom.reportRead();
    return super.answers;
  }

  @override
  set answers(ObservableMap<int, String> value) {
    _$answersAtom.reportWrite(value, super.answers, () {
      super.answers = value;
    });
  }

  late final _$answeredAtom =
      Atom(name: '_TestStore.answered', context: context);

  @override
  ObservableSet<int> get answered {
    _$answeredAtom.reportRead();
    return super.answered;
  }

  @override
  set answered(ObservableSet<int> value) {
    _$answeredAtom.reportWrite(value, super.answered, () {
      super.answered = value;
    });
  }

  late final _$markedAtom = Atom(name: '_TestStore.marked', context: context);

  @override
  ObservableSet<int> get marked {
    _$markedAtom.reportRead();
    return super.marked;
  }

  @override
  set marked(ObservableSet<int> value) {
    _$markedAtom.reportWrite(value, super.marked, () {
      super.marked = value;
    });
  }

  late final _$skippedAtom = Atom(name: '_TestStore.skipped', context: context);

  @override
  ObservableSet<int> get skipped {
    _$skippedAtom.reportRead();
    return super.skipped;
  }

  @override
  set skipped(ObservableSet<int> value) {
    _$skippedAtom.reportWrite(value, super.skipped, () {
      super.skipped = value;
    });
  }

  late final _$timeSpentPerQuestionAtom =
      Atom(name: '_TestStore.timeSpentPerQuestion', context: context);

  @override
  ObservableMap<int, int> get timeSpentPerQuestion {
    _$timeSpentPerQuestionAtom.reportRead();
    return super.timeSpentPerQuestion;
  }

  @override
  set timeSpentPerQuestion(ObservableMap<int, int> value) {
    _$timeSpentPerQuestionAtom.reportWrite(value, super.timeSpentPerQuestion,
        () {
      super.timeSpentPerQuestion = value;
    });
  }

  late final _$startedAtAtom =
      Atom(name: '_TestStore.startedAt', context: context);

  @override
  DateTime? get startedAt {
    _$startedAtAtom.reportRead();
    return super.startedAt;
  }

  @override
  set startedAt(DateTime? value) {
    _$startedAtAtom.reportWrite(value, super.startedAt, () {
      super.startedAt = value;
    });
  }

  late final _$loadAssessmentAsyncAction =
      AsyncAction('_TestStore.loadAssessment', context: context);

  @override
  Future<void> loadAssessment(String id) {
    return _$loadAssessmentAsyncAction.run(() => super.loadAssessment(id));
  }

  late final _$submitTestAsyncAction =
      AsyncAction('_TestStore.submitTest', context: context);

  @override
  Future<bool> submitTest(String studentId) {
    return _$submitTestAsyncAction.run(() => super.submitTest(studentId));
  }

  late final _$_TestStoreActionController =
      ActionController(name: '_TestStore', context: context);

  @override
  void setAnswer(int index, String value) {
    final _$actionInfo =
        _$_TestStoreActionController.startAction(name: '_TestStore.setAnswer');
    try {
      return super.setAnswer(index, value);
    } finally {
      _$_TestStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleMarked(int index) {
    final _$actionInfo = _$_TestStoreActionController.startAction(
        name: '_TestStore.toggleMarked');
    try {
      return super.toggleMarked(index);
    } finally {
      _$_TestStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSkipped(int index) {
    final _$actionInfo =
        _$_TestStoreActionController.startAction(name: '_TestStore.setSkipped');
    try {
      return super.setSkipped(index);
    } finally {
      _$_TestStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentIndex(int index) {
    final _$actionInfo = _$_TestStoreActionController.startAction(
        name: '_TestStore.setCurrentIndex');
    try {
      return super.setCurrentIndex(index);
    } finally {
      _$_TestStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void recordTime(int index, int seconds) {
    final _$actionInfo =
        _$_TestStoreActionController.startAction(name: '_TestStore.recordTime');
    try {
      return super.recordTime(index, seconds);
    } finally {
      _$_TestStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo =
        _$_TestStoreActionController.startAction(name: '_TestStore.reset');
    try {
      return super.reset();
    } finally {
      _$_TestStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
currentAssessment: ${currentAssessment},
currentIndex: ${currentIndex},
answers: ${answers},
answered: ${answered},
marked: ${marked},
skipped: ${skipped},
timeSpentPerQuestion: ${timeSpentPerQuestion},
startedAt: ${startedAt},
totalQuestions: ${totalQuestions}
    ''';
  }
}
