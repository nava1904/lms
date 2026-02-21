import { defineType, defineField } from 'sanity'
import { ClipboardIcon } from '@sanity/icons'

export const assessment = defineType({
  name: 'assessment',
  title: 'Assessment',
  type: 'document',
  icon: ClipboardIcon,
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'assessmentType',
      title: 'Assessment Type',
      type: 'string',
      options: {
        list: [
          { title: 'Quiz', value: 'quiz' },
          { title: 'Midterm', value: 'midterm' },
          { title: 'Final', value: 'final' },
          { title: 'Practice', value: 'practice' },
          { title: 'Assignment', value: 'assignment' },
        ],
      },
    }),
    defineField({
      name: 'subject',
      title: 'Subject',
      type: 'reference',
      to: [{ type: 'subject' }],
    }),
    defineField({
      name: 'durationMinutes',
      title: 'Duration (minutes)',
      type: 'number',
    }),
    defineField({
      name: 'totalMarks',
      title: 'Total Marks',
      type: 'number',
    }),
    defineField({
      name: 'passingMarksPercent',
      title: 'Passing Marks (%)',
      type: 'number',
      validation: (Rule) => Rule.min(0).max(100),
    }),
    defineField({
      name: 'worksheet',
      title: 'Worksheet',
      type: 'reference',
      to: [{ type: 'worksheet' }],
    }),
    defineField({
      name: 'isPublished',
      title: 'Is Published',
      type: 'boolean',
      initialValue: false,
    }),
  ],
  preview: {
    select: {
      title: 'title',
      subtitle: 'assessmentType',
    },
  },
})
