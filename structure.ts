import type { StructureResolver } from 'sanity/structure'
import {
  BookIcon,
  DocumentIcon,
  ClipboardIcon,
  UserIcon,
  CalendarIcon,
  CheckmarkCircleIcon,
  CommentIcon,
  RobotIcon,
} from '@sanity/icons'

export const structure: StructureResolver = (S) =>
  S.list()
    .title('📚 LMS Dashboard')
    .items([
      // SECTION 1: LEARNING PATHS & COURSES
      S.listItem()
        .title('🎓 Learning Paths & Courses')
        .icon(BookIcon)
        .child(
          S.list()
            .title('Learning Content')
            .items([
              S.documentTypeListItem('course').title('🎯 Courses'),
              S.documentTypeListItem('subject').title('📖 Subjects'),
              S.documentTypeListItem('chapter').title('📑 Chapters'),
              S.documentTypeListItem('concept').title('📝 Lessons'),
              S.divider(),
              S.documentTypeListItem('resource').title('📎 Resources'),
              S.documentTypeListItem('assignment').title('✏️ Assignments'),
            ])
        ),

      S.divider(),

      // SECTION 2: ASSESSMENTS & TESTING
      S.listItem()
        .title('📊 Assessments & Testing')
        .icon(ClipboardIcon)
        .child(
          S.list()
            .title('Assessments')
            .items([
              S.documentTypeListItem('test').title('📋 Tests/Exams'),
              S.documentTypeListItem('testAttempt').title('✅ Test Results'),
              S.documentTypeListItem('question').title('❓ Question Bank'),
            ])
        ),

      S.divider(),

      // SECTION 3: USER MANAGEMENT
      S.listItem()
        .title('👥 User Management')
        .icon(UserIcon)
        .child(
          S.list()
            .title('Users & Access Control')
            .items([
              S.documentTypeListItem('student').title('🎓 Students'),
              S.documentTypeListItem('teacher').title('👨‍🏫 Teachers'),
              S.documentTypeListItem('admin').title('⚙️ Admins'),
              S.divider(),
              S.documentTypeListItem('enrollment').title('📝 Enrollments'),
            ])
        ),

      S.divider(),

      // SECTION 4: TRACKING & ANALYTICS
      S.listItem()
        .title('📈 Tracking & Analytics')
        .icon(CheckmarkCircleIcon)
        .child(
          S.list()
            .title('Student Performance')
            .items([
              S.documentTypeListItem('progress').title('📊 Progress'),
              S.documentTypeListItem('attendance').title('✅ Attendance'),
              S.documentTypeListItem('discussion').title('💬 Discussions'),
            ])
        ),
    ])
