import { defineType, defineField } from 'sanity'
import { UserIcon } from '@sanity/icons'

export const teacher = defineType({
  name: 'teacher',
  title: 'Teacher',
  type: 'document',
  icon: UserIcon,
  fields: [
    defineField({
      name: 'name',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'email',
      type: 'string',
      validation: (rule) => rule.email().required(),
    }),
    defineField({
      name: 'employeeId',
      type: 'string',
      validation: (rule) => rule.required(),
      description: 'Unique employee ID for the teacher',
    }),
    defineField({
      name: 'subjects',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'subject' }] }],
      title: 'Assigned Subjects',
      description: 'Subjects this teacher teaches',
    }),
    defineField({
      name: 'qualifications',
      type: 'text',
      title: 'Qualifications',
    }),
    defineField({
      name: 'bio',
      type: 'text',
      title: 'Bio/About',
    }),
  ],
})
