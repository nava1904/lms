import { defineType, defineField } from 'sanity'

export const attendance = defineType({
  name: 'attendance',
  title: 'Attendance',
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
      name: 'date',
      title: 'Date',
      type: 'date',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          { title: 'Present', value: 'present' },
          { title: 'Absent', value: 'absent' },
          { title: 'Late', value: 'late' },
          { title: 'Excused', value: 'excused' },
        ],
      },
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'subject',
      title: 'Subject',
      type: 'reference',
      to: [{ type: 'subject' }],
    }),
    defineField({
      name: 'remarks',
      title: 'Remarks',
      type: 'string',
    }),
    defineField({
      name: 'markedBy',
      title: 'Marked By',
      type: 'reference',
      to: [{ type: 'teacher' }],
    }),
  ],
  preview: {
    select: {
      title: 'student.name',
      subtitle: 'date',
      status: 'status',
    },
    prepare({ title, subtitle, status }) {
      const emoji =
        status === 'present'
          ? '✅'
          : status === 'absent'
          ? '❌'
          : '⏰'
      return {
        title: `${emoji} ${title || 'Unknown'}`,
        subtitle,
      }
    },
  },
})
