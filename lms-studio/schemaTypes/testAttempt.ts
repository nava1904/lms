import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'testAttempt',
  title: 'Test Attempt',
  type: 'document',
  fields: [
    defineField({
      name: 'test',
      title: 'Test',
      type: 'reference',
      to: [{ type: 'test' }],
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'student',
      title: 'Student',
      type: 'reference',
      to: [{ type: 'student' }],
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'answers',
      title: 'Answers',
      type: 'array',
      of: [
        {
          type: 'object',
          fields: [
            { name: 'question', type: 'reference', to: [{ type: 'question' }] },
            { name: 'answer', type: 'string' },
            { name: 'isCorrect', type: 'boolean' },
            { name: 'marksObtained', type: 'number' },
          ],
        },
      ],
    }),
    defineField({
      name: 'score',
      title: 'Score',
      type: 'number',
    }),
    defineField({
      name: 'percentage',
      title: 'Percentage',
      type: 'number',
    }),
    defineField({
      name: 'passed',
      title: 'Passed',
      type: 'boolean',
    }),
    defineField({
      name: 'startedAt',
      title: 'Started At',
      type: 'datetime',
    }),
    defineField({
      name: 'submittedAt',
      title: 'Submitted At',
      type: 'datetime',
    }),
    defineField({
      name: 'timeSpent',
      title: 'Time Spent (minutes)',
      type: 'number',
    }),
  ],
  preview: {
    select: {
      title: 'student.name',
      subtitle: 'test.title',
      passed: 'passed',
      score: 'score',
    },
    prepare({ title, subtitle, passed, score }) {
      return {
        title: `${passed ? '✅' : '❌'} ${title || 'Unknown Student'}`,
        subtitle: `${subtitle || 'Unknown Test'} - Score: ${score || 0}`,
      }
    },
  },
})
