import { defineType, defineField } from 'sanity'
import { BookIcon } from '@sanity/icons'

export const subject = defineType({
  name: 'subject',
  title: 'Subject',
  type: 'document',
  icon: BookIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'classLevel',
      type: 'string',
      title: 'Class Level',
      description: 'e.g., 11, 12, JEE, NEET',
    }),
    defineField({
      name: 'icon',
      type: 'image',
      title: 'Subject Icon',
      options: {
        hotspot: true,
      },
    }),
    defineField({
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      description: 'Course this subject belongs to',
    }),
    defineField({
      name: 'chapters',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'chapter' }] }],
      title: 'Chapters',
    }),
    defineField({
      name: 'teachers',
      type: 'array',
      of: [{ type: 'reference', to: [{ type: 'teacher' }], weak: true }],
      title: 'Teachers',
      description: 'Teachers assigned to this subject',
    }),
  ],
})