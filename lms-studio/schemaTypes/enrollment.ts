import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'enrollment',
  title: 'Enrollment',
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
      name: 'course',
      title: 'Course',
      type: 'reference',
      to: [{ type: 'course' }],
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'enrolledAt',
      title: 'Enrolled At',
      type: 'datetime',
      initialValue: () => new Date().toISOString(),
    }),
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          { title: 'Active', value: 'active' },
          { title: 'Completed', value: 'completed' },
          { title: 'Dropped', value: 'dropped' },
          { title: 'Suspended', value: 'suspended' },
        ],
      },
      initialValue: 'active',
    }),
    defineField({
      name: 'completedAt',
      title: 'Completed At',
      type: 'datetime',
    }),
  ],
  preview: {
    select: {
      title: 'student.name',
      subtitle: 'course.title',
      status: 'status',
    },
    prepare({ title, subtitle, status }) {
      return {
        title: title || 'Unknown Student',
        subtitle: `${subtitle || 'Unknown Course'} - ${status}`,
      }
    },
  },
})
