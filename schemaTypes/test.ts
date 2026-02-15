import { defineType, defineField } from 'sanity'
import { ClipboardIcon } from '@sanity/icons'

export const test = defineType({
  name: 'test',
  title: 'Test',
  type: 'document',
  icon: ClipboardIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'subject',
      type: 'reference',
      to: [{ type: 'subject' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'description',
      type: 'text',
    }),
    defineField({
      name: 'totalMarks',
      type: 'number',
      validation: (rule) => rule.required().positive(),
    }),
    defineField({
      name: 'duration',
      type: 'number',
      title: 'Duration (minutes)',
      validation: (rule) => rule.required().positive(),
    }),
    defineField({
      name: 'scheduledDate',
      type: 'datetime',
      title: 'Scheduled Date & Time',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'questions',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'question' }] }],
    }),
    defineField({
      name: 'status',
      type: 'string',
      options: {
        list: [
          { title: 'Scheduled', value: 'scheduled' },
          { title: 'Active', value: 'active' },
          { title: 'Completed', value: 'completed' },
        ],
      },
      validation: (rule) => rule.required(),
    }),
  ],
})
