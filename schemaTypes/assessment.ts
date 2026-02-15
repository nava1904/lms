import { defineType, defineField } from 'sanity'
import { ClipboardIcon } from '@sanity/icons'

export const assessment = defineType({
  name: 'assessment',
  title: 'Assessment / Test',
  type: 'document',
  icon: ClipboardIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'slug',
      type: 'slug',
      options: { source: 'title' },
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'worksheet',
      type: 'reference',
      to: [{ type: 'worksheet' }],
      description: 'Worksheet whose questions are used for this test',
    }),
    defineField({
      name: 'durationMinutes',
      title: 'Duration (minutes)',
      type: 'number',
      validation: (rule) => rule.required().min(1),
      initialValue: 30,
    }),
    defineField({
      name: 'openInSeparateWindow',
      title: 'Open in separate test window',
      type: 'boolean',
      initialValue: true,
      description: 'When true, test is attempted in a dedicated full-screen window',
    }),
    defineField({
      name: 'passingMarksPercent',
      title: 'Passing marks (%)',
      type: 'number',
      initialValue: 40,
    }),
    defineField({
      name: 'type',
      type: 'string',
      title: 'Type',
    }),
    defineField({
      name: 'questions',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'question' }] }],
      title: 'Questions',
    }),
    defineField({
      name: 'duration',
      type: 'number',
      title: 'Duration (minutes)',
    }),
  ],
})

export const test = {
  name: 'test',
  type: 'document',
  title: 'Test',
  fields: [
    { name: 'type', type: 'string', title: 'Type' },
    { name: 'questions', type: 'array', of: [{ type: 'reference', to: [{ type: 'question' }] }], title: 'Questions' },
    { name: 'duration', type: 'number', title: 'Duration (minutes)' },
  ],
}
