import { defineType, defineField } from 'sanity'
import { DocumentIcon } from '@sanity/icons'

export const resource = defineType({
  name: 'resource',
  title: 'Resource',
  type: 'document',
  icon: DocumentIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'description',
      type: 'text',
    }),
    defineField({
      name: 'type',
      type: 'string',
      options: {
        list: [
          { title: 'PDF', value: 'pdf' },
          { title: 'Document', value: 'document' },
          { title: 'Image', value: 'image' },
          { title: 'Video', value: 'video' },
          { title: 'Link', value: 'link' },
        ],
      },
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'file',
      type: 'file',
      title: 'Upload File',
    }),
    defineField({
      name: 'url',
      type: 'url',
      title: 'External URL',
    }),
    defineField({
      name: 'chapter',
      type: 'reference',
      to: [{ type: 'chapter' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'subject',
      type: 'reference',
      to: [{ type: 'subject' }],
    }),
  ],
})
