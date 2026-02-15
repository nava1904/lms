import { defineType, defineField, defineArrayMember } from 'sanity'
import { DocumentIcon } from '@sanity/icons'

export const concept = defineType({
  name: 'concept',
  title: 'Concept / Content',
  type: 'document',
  icon: DocumentIcon,
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
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      description: 'Parent course/chapter',
    }),
    defineField({
      name: 'body',
      type: 'array',
      of: [
        defineArrayMember({ type: 'block' }),
        defineArrayMember({
          type: 'image',
          options: { hotspot: true },
          fields: [
            defineField({ name: 'alt', type: 'string', title: 'Alt text' }),
            defineField({ name: 'caption', type: 'string' }),
          ],
        }),
      ],
      description: 'Concept content (text, equations, images)',
    }),
    defineField({
      name: 'prerequisites',
      type: 'array',
      of: [defineArrayMember({ type: 'reference', to: [{ type: 'concept' }] })],
      description: 'Prerequisite concepts for concept graph',
    }),
    defineField({
      name: 'order',
      type: 'number',
      initialValue: 0,
    }),
  ],
  orderings: [
    { title: 'Order', name: 'orderAsc', by: [{ field: 'order', direction: 'asc' }] },
  ],
})

export const chapter = {
  name: 'chapter',
  type: 'document',
  title: 'Chapter',
  fields: [
    { name: 'conceptGraphs', type: 'array', of: [{ type: 'image' }], title: 'Concept Graphs' },
    { name: 'theory', type: 'text', title: 'Theory' },
    { name: 'videos', type: 'array', of: [{ type: 'url' }], title: 'Videos' },
    { name: 'practiceSheets', type: 'array', of: [{ type: 'file' }], title: 'Practice Sheets' },
  ],
}
