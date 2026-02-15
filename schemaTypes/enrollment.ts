import { defineType, defineField } from 'sanity'
import { UserIcon } from '@sanity/icons'

export const enrollment = defineType({
  name: 'enrollment',
  title: 'Enrollment',
  type: 'document',
  icon: UserIcon,
  fields: [
    defineField({
      name: 'student',
      type: 'reference',
      to: [{ type: 'student' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'enrollmentDate',
      type: 'datetime',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'completionDate',
      type: 'datetime',
      title: 'Completion Date',
    }),
    defineField({
      name: 'status',
      type: 'string',
      options: {
        list: [
          { title: 'Active', value: 'active' },
          { title: 'Completed', value: 'completed' },
          { title: 'Dropped', value: 'dropped' },
        ],
      },
      initialValue: 'active',
    }),
    defineField({
      name: 'progressPercentage',
      type: 'number',
      title: 'Progress %',
      validation: (rule) => rule.min(0).max(100),
    }),
    defineField({
      name: 'certificateIssued',
      type: 'boolean',
      initialValue: false,
    }),
  ],
})
