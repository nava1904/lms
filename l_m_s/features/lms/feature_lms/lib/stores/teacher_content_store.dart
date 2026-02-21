import 'package:mobx/mobx.dart';

part 'teacher_content_store.g.dart';

class TeacherContentStore = _TeacherContentStore with _$TeacherContentStore;

abstract class _TeacherContentStore with Store {
  @observable
  ObservableList<Map<String, dynamic>> subjects = ObservableList<Map<String, dynamic>>();

  @observable
  ObservableList<Map<String, dynamic>> chapters = ObservableList<Map<String, dynamic>>();

  @observable
  ObservableList<Map<String, dynamic>> tests = ObservableList<Map<String, dynamic>>();

  @observable
  ObservableList<Map<String, dynamic>> questions = ObservableList<Map<String, dynamic>>();

  @action
  void setSubjects(List<Map<String, dynamic>> list) {
    subjects = ObservableList<Map<String, dynamic>>.of(list);
  }

  @action
  void setChapters(List<Map<String, dynamic>> list) {
    chapters = ObservableList<Map<String, dynamic>>.of(list);
  }

  @action
  void setTests(List<Map<String, dynamic>> list) {
    tests = ObservableList<Map<String, dynamic>>.of(list);
  }

  @action
  void setQuestions(List<Map<String, dynamic>> list) {
    questions = ObservableList<Map<String, dynamic>>.of(list);
  }

  @action
  void addSubject(Map<String, dynamic> subject) {
    subjects = ObservableList<Map<String, dynamic>>.of([...subjects, subject]);
  }

  @action
  void addChapter(Map<String, dynamic> chapter) {
    chapters = ObservableList<Map<String, dynamic>>.of([...chapters, chapter]);
  }

  @action
  void addQuestion(Map<String, dynamic> question) {
    questions = ObservableList<Map<String, dynamic>>.of([...questions, question]);
  }
}
