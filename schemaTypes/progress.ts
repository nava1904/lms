import { defineType, defineField } from 'sanity'
import { CheckmarkCircleIcon } from '@sanity/icons'

export const progress = defineType({
  name: 'progress',
  title: 'Student Progress',
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
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'chaptersCompleted',
      type: 'number',
      title: 'Chapters Completed',
    }),
    defineField({
      name: 'videosWatched',
      type: 'number',
      title: 'Videos Watched',
    }),
    defineField({
      name: 'assignmentsSubmitted',
      type: 'number',
      title: 'Assignments Submitted',
    }),
    defineField({
      name: 'testsTaken',
      type: 'number',
      title: 'Tests Taken',
    }),
    defineField({
      name: 'averageScore',
      type: 'number',
      title: 'Average Test Score',
      validation: (rule) => rule.min(0).max(100),
    }),
    defineField({
      name: 'overallProgress',
      type: 'number',
      title: 'Overall Progress %',
      validation: (rule) => rule.min(0).max(100),
    }),
    defineField({
      name: 'lastAccessedAt',
      type: 'datetime',
      title: 'Last Accessed',
    }),
    defineField({
      name: 'learningStreak',
      type: 'number',
      title: 'Learning Streak (days)',
    }),
  ],
})
