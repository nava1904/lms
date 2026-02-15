import { defineType, defineField, defineArrayMember } from 'sanity'
import { CheckmarkCircleIcon } from '@sanity/icons'

export const testAttempt = defineType({
  name: 'testAttempt',
  title: 'Test Attempt',
  type: 'document',
  icon: CheckmarkCircleIcon,
  fields: [
    defineField({
      name: 'student',
      type: 'reference',
      to: [{ type: 'student' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'test',
      type: 'reference',
      to: [{ type: 'test' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'score',
      type: 'number',
      validation: (rule) => rule.required().min(0),
    }),
    defineField({
      name: 'totalMarks',
      type: 'number',
      validation: (rule) => rule.required().positive(),
    }),
    defineField({
      name: 'percentage',
      type: 'number',
      title: 'Percentage (%)',
    }),
    defineField({
      name: 'startedAt',
      type: 'datetime',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'completedAt',
      type: 'datetime',
    }),
    defineField({
      name: 'duration',
      type: 'number',
      title: 'Time Taken (seconds)',
    }),
    defineField({
      name: 'status',
      type: 'string',
      options: {
        list: [
          { title: 'In Progress', value: 'in_progress' },
          { title: 'Submitted', value: 'submitted' },
        ],
      },
    }),
  ],
  orderings: [
    {
      title: 'Submitted (newest)',
      name: 'submittedDesc',
      by: [{ field: 'submittedAt', direction: 'desc' }],
    },
    {
      title: 'Started (newest)',
      name: 'startedDesc',
      by: [{ field: 'startedAt', direction: 'desc' }],
    },
    {
      title: 'Score (highest)',
      name: 'scoreDesc',
      by: [{ field: 'scorePercent', direction: 'desc' }],
    },
  ],
  preview: {
    select: {
      studentName: 'student.name',
      testTitle: 'test.title',
      score: 'scorePercent',
      submitted: 'submittedAt',
      started: 'startedAt',
      passed: 'isPassed',
    },
    prepare({ studentName, testTitle, score, submitted, started, passed }) {
      const status = submitted
        ? score != null
          ? `${score}% ${passed ? '✅ Passed' : '❌ Failed'}`
          : 'Submitted'
        : started
          ? 'In progress'
          : 'Not started'
      return {
        title: `${studentName || 'Unknown'} - ${testTitle || 'Test'}`,
        subtitle: status,
      }
    },
  },
})
