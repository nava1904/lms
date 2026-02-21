// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_content_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TeacherContentStore on _TeacherContentStore, Store {
  late final _$subjectsAtom =
      Atom(name: '_TeacherContentStore.subjects', context: context);

  @override
  ObservableList<Map<String, dynamic>> get subjects {
    _$subjectsAtom.reportRead();
    return super.subjects;
  }

  @override
  set subjects(ObservableList<Map<String, dynamic>> value) {
    _$subjectsAtom.reportWrite(value, super.subjects, () {
      super.subjects = value;
    });
  }

  late final _$chaptersAtom =
      Atom(name: '_TeacherContentStore.chapters', context: context);

  @override
  ObservableList<Map<String, dynamic>> get chapters {
    _$chaptersAtom.reportRead();
    return super.chapters;
  }

  @override
  set chapters(ObservableList<Map<String, dynamic>> value) {
    _$chaptersAtom.reportWrite(value, super.chapters, () {
      super.chapters = value;
    });
  }

  late final _$testsAtom =
      Atom(name: '_TeacherContentStore.tests', context: context);

  @override
  ObservableList<Map<String, dynamic>> get tests {
    _$testsAtom.reportRead();
    return super.tests;
  }

  @override
  set tests(ObservableList<Map<String, dynamic>> value) {
    _$testsAtom.reportWrite(value, super.tests, () {
      super.tests = value;
    });
  }

  late final _$questionsAtom =
      Atom(name: '_TeacherContentStore.questions', context: context);

  @override
  ObservableList<Map<String, dynamic>> get questions {
    _$questionsAtom.reportRead();
    return super.questions;
  }

  @override
  set questions(ObservableList<Map<String, dynamic>> value) {
    _$questionsAtom.reportWrite(value, super.questions, () {
      super.questions = value;
    });
  }

  late final _$_TeacherContentStoreActionController =
      ActionController(name: '_TeacherContentStore', context: context);

  @override
  void setSubjects(List<Map<String, dynamic>> list) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.setSubjects');
    try {
      return super.setSubjects(list);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChapters(List<Map<String, dynamic>> list) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.setChapters');
    try {
      return super.setChapters(list);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTests(List<Map<String, dynamic>> list) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.setTests');
    try {
      return super.setTests(list);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setQuestions(List<Map<String, dynamic>> list) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.setQuestions');
    try {
      return super.setQuestions(list);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addSubject(Map<String, dynamic> subject) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.addSubject');
    try {
      return super.addSubject(subject);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addChapter(Map<String, dynamic> chapter) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.addChapter');
    try {
      return super.addChapter(chapter);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addQuestion(Map<String, dynamic> question) {
    final _$actionInfo = _$_TeacherContentStoreActionController.startAction(
        name: '_TeacherContentStore.addQuestion');
    try {
      return super.addQuestion(question);
    } finally {
      _$_TeacherContentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
subjects: ${subjects},
chapters: ${chapters},
tests: ${tests},
questions: ${questions}
    ''';
  }
}
