import { defineType, defineField } from 'sanity'
import { BookIcon } from '@sanity/icons'

export const chapter = defineType({
  name: 'chapter',
  title: 'Chapter',
  type: 'document',
  icon: BookIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'description',
      type: 'text',
      title: 'Description',
    }),
    defineField({
      name: 'subject',
      type: 'reference',
      to: [{ type: 'subject' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'order',
      type: 'number',
      title: 'Order',
      description: 'Chapter order in subject',
    }),
    defineField({
      name: 'duration',
      type: 'string',
      title: 'Duration',
      description: 'e.g., "1h 20m"',
    }),
    defineField({
      name: 'isFreePreview',
      type: 'boolean',
      title: 'Free Preview',
      description: 'Allow students to preview before enrollment',
      initialValue: false,
    }),
  ],
})
