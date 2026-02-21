import course from './course'
import subject from './subject'
import chapter from './chapter'
import { concept } from './concept'
import batch from './batch'
import student from './student'
import teacher from './teacher'
import admin from './admin'
import test from './test'
import question from './question'
import testAttempt from './testAttempt'
import {attendance} from './attendance'
import enrollment from './enrollment'
import progress from './progress'
import resource from './resource'
import assignment from './assignment'
import discussion from './discussion'
import {worksheet} from './worksheet'
import {assessment} from './assessment'
import adBanner from './adBanner'

export const schemaTypes = [
  // Learning Content (hierarchical)
  course,
  subject,
  chapter,
  concept,

  // Assessments
  test,
  question,
  worksheet,
  assessment,
  testAttempt,

  // Users
  batch,
  student,
  teacher,
  admin,

  // Tracking
  attendance,
  enrollment,
  progress,

  // Extras
  resource,
  assignment,
  discussion,
  adBanner,
]