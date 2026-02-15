import { defineType, defineField } from 'sanity'
import { DocumentTextIcon } from '@sanity/icons'

export const assignment = defineType({
  name: 'assignment',
  title: 'Assignment',
  type: 'document',
  icon: DocumentTextIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'description',
      type: 'text',
      title: 'Assignment Description',
    }),
    defineField({
      name: 'instructions',
      type: 'array',
      of: [{ type: 'block' }],
      title: 'Instructions',
    }),
    defineField({
      name: 'chapter',
      type: 'reference',
      to: [{ type: 'chapter' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'subject',
      type: 'reference',
      to: [{ type: 'subject' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'dueDate',
      type: 'datetime',
      title: 'Due Date',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'totalMarks',
      type: 'number',
      title: 'Total Marks',
      validation: (rule) => rule.required().positive(),
    }),
    defineField({
      name: 'attachments',
      type: 'array',
      of: [
        {
          type: 'object',
          fields: [
            defineField({ name: 'name', type: 'string' }),
            defineField({ name: 'file', type: 'file' }),
          ],
        },
      ],
      title: 'Attachments',
    }),
    defineField({
      name: 'status',
      type: 'string',
      options: {
        list: [
          { title: 'Draft', value: 'draft' },
          { title: 'Published', value: 'published' },
          { title: 'Closed', value: 'closed' },
        ],
      },
      initialValue: 'draft',
    }),
  ],
})
