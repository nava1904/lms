import { defineType, defineField } from 'sanity'
import { UserIcon } from '@sanity/icons'

export const student = defineType({
  name: 'student',
  title: 'Student',
  type: 'document',
  icon: UserIcon,
  fields: [
    defineField({
      name: 'name',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'rollNumber',
      type: 'string',
      validation: (rule) => rule.required(),
      description: 'Unique roll number for the student',
    }),
    defineField({
      name: 'email',
      type: 'string',
      validation: (rule) => rule.email().required(),
    }),
    defineField({
      name: 'externalId',
      title: 'External ID',
      type: 'string',
      description: 'ID from auth system (e.g. Firebase UID) for linking',
    }),
    defineField({
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      description: 'Primary course enrollment',
    }),
    defineField({
      name: 'enrolledSubjects',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'subject' }] }],
      title: 'Enrolled Subjects',
      description: 'Subjects this student is enrolled in',
    }),
  ],
})
