import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'batch',
  title: 'Batch',
  type: 'document',
  fields: [
    defineField({
      name: 'name',
      title: 'Batch Name',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
    }),
    defineField({
      name: 'course',
      title: 'Course',
      type: 'reference',
      to: [{ type: 'course' }],
    }),
    defineField({
      name: 'startDate',
      title: 'Start Date',
      type: 'date',
    }),
    defineField({
      name: 'endDate',
      title: 'End Date',
      type: 'date',
    }),
  ],
  preview: {
    select: { title: 'name' },
  },
})
