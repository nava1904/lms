import { defineType, defineField } from 'sanity'
import { CommentIcon } from '@sanity/icons'

export const discussion = defineType({
  name: 'discussion',
  title: 'Discussion',
  type: 'document',
  icon: CommentIcon,
  fields: [
    defineField({
      name: 'title',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'content',
      type: 'array',
      of: [{ type: 'block' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'author',
      type: 'reference',
      to: [{ type: 'student' }, { type: 'teacher' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'chapter',
      type: 'reference',
      to: [{ type: 'chapter' }],
    }),
    defineField({
      name: 'replies',
      type: 'array',
      of: [
        {
          type: 'object',
          fields: [
            defineField({
              name: 'author',
              type: 'reference',
              to: [{ type: 'student' }, { type: 'teacher' }],
            }),
            defineField({ name: 'content', type: 'text' }),
            defineField({ name: 'createdAt', type: 'datetime' }),
            defineField({ name: 'likes', type: 'number', initialValue: 0 }),
          ],
        },
      ],
    }),
    defineField({
      name: 'createdAt',
      type: 'datetime',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'isPinned',
      type: 'boolean',
      initialValue: false,
      title: 'Pin This Discussion',
    }),
    defineField({
      name: 'likes',
      type: 'number',
      initialValue: 0,
    }),
  ],
})
