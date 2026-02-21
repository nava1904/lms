import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'discussion',
  title: 'Discussion',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      title: 'Title',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'content',
      title: 'Content',
      type: 'array',
      of: [{ type: 'block' }],
    }),
    defineField({
      name: 'author',
      title: 'Author',
      type: 'reference',
      to: [{ type: 'student' }, { type: 'teacher' }],
    }),
    defineField({
      name: 'chapter',
      title: 'Related Chapter',
      type: 'reference',
      to: [{ type: 'chapter' }],
    }),
    defineField({
      name: 'concept',
      title: 'Related Concept',
      type: 'reference',
      to: [{ type: 'concept' }],
    }),
    defineField({
      name: 'replies',
      title: 'Replies',
      type: 'array',
      of: [
        {
          type: 'object',
          fields: [
            { name: 'author', type: 'reference', to: [{ type: 'student' }, { type: 'teacher' }] },
            { name: 'content', type: 'text' },
            { name: 'createdAt', type: 'datetime' },
          ],
        },
      ],
    }),
    defineField({
      name: 'createdAt',
      title: 'Created At',
      type: 'datetime',
      initialValue: () => new Date().toISOString(),
    }),
    defineField({
      name: 'isResolved',
      title: 'Is Resolved',
      type: 'boolean',
      initialValue: false,
    }),
  ],
  preview: {
    select: {
      title: 'title',
      subtitle: 'author.name',
    },
  },
})
