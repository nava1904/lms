import { defineType, defineField } from 'sanity'
import { BookIcon } from '@sanity/icons'

export const course = defineType({
  name: 'course',
  title: 'Course',
  type: 'document',
  icon: BookIcon,
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
      name: 'description',
      type: 'text',
    }),
    defineField({
      name: 'order',
      type: 'number',
      initialValue: 0,
      description: 'Display order',
    }),
    defineField({
      name: 'thumbnail',
      type: 'image',
      title: 'Course Thumbnail',
      options: {
        hotspot: true,
      },
      description: 'Main image for the course card',
    }),
    defineField({
      name: 'rating',
      type: 'number',
      title: 'Rating (0-5)',
      validation: (rule) => rule.min(0).max(5),
    }),
    defineField({
      name: 'tags',
      type: 'array',
      of: [{ type: 'string' }],
      options: {
        layout: 'tags',
      },
      description: 'e.g., JEE, Class 11, NEET',
    }),
    defineField({
      name: 'features',
      type: 'array',
      of: [{ type: 'string' }],
      title: 'Course Features',
      description: 'e.g., "10 hrs video", "Certificate"',
    }),
    defineField({
      name: 'subjects',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'subject' }] }],
    }),
  ],
  orderings: [
    { title: 'Order', name: 'orderAsc', by: [{ field: 'order', direction: 'asc' }] },
    { title: 'Title', name: 'titleAsc', by: [{ field: 'title', direction: 'asc' }] },
  ],
})
