import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'progress',
  title: 'Progress',
  type: 'document',
  fields: [
    defineField({
      name: 'student',
      title: 'Student',
      type: 'reference',
      to: [{ type: 'student' }],
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'concept',
      title: 'Concept',
      type: 'reference',
      to: [{ type: 'concept' }],
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'completed',
      title: 'Completed',
      type: 'boolean',
      initialValue: false,
    }),
    defineField({
      name: 'completedAt',
      title: 'Completed At',
      type: 'datetime',
    }),
    defineField({
      name: 'score',
      title: 'Score (%)',
      type: 'number',
      validation: (Rule) => Rule.min(0).max(100),
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
      subtitle: 'concept.title',
      completed: 'completed',
    },
    prepare({ title, subtitle, completed }) {
      return {
        title: `${completed ? '✅' : '⏳'} ${title || 'Unknown Student'}`,
        subtitle: subtitle,
      }
    },
  },
})
