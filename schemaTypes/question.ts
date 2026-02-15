import { defineType, defineField, defineArrayMember } from 'sanity'
import { HelpCircleIcon } from '@sanity/icons'

export const question = defineType({
  name: 'question',
  title: 'Question',
  type: 'document',
  icon: HelpCircleIcon,
  fields: [
    defineField({
      name: 'text',
      type: 'text',
      title: 'Text (LaTeX supported)',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'options',
      type: 'array',
      of: [{ type: 'string' }],
      title: 'Options',
    }),
    defineField({
      name: 'solution',
      type: 'text',
      title: 'Solution',
    }),
    defineField({
      name: 'questionRich',
      title: 'Question (rich text)',
      type: 'array',
      of: [
        defineArrayMember({ type: 'block' }),
        defineArrayMember({
          type: 'image',
          options: { hotspot: true },
          fields: [
            defineField({ name: 'alt', type: 'string' }),
            defineField({ name: 'caption', type: 'string' }),
          ],
        }),
      ],
      description: 'Optional rich question (blocks + images). Used if set, else queText.',
    }),
    defineField({
      name: 'type',
      type: 'string',
      options: {
        list: [
          { title: 'Multiple choice', value: 'mcq' },
          { title: 'Short answer', value: 'short' },
          { title: 'Long answer', value: 'long' },
        ],
        layout: 'radio',
      },
      initialValue: 'mcq',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'solutionRich',
      title: 'Solution (rich)',
      type: 'array',
      of: [
        defineArrayMember({ type: 'block' }),
        defineArrayMember({
          type: 'image',
          options: { hotspot: true },
          fields: [
            defineField({ name: 'alt', type: 'string' }),
            defineField({ name: 'caption', type: 'string' }),
          ],
        }),
      ],
      description: 'Optional rich solution. Used if set, else solution.',
    }),
    defineField({
      name: 'imageInQue',
      title: 'Image in question',
      type: 'image',
      options: { hotspot: true },
      fields: [
        defineField({ name: 'alt', type: 'string' }),
        defineField({ name: 'caption', type: 'string' }),
      ],
    }),
    defineField({
      name: 'imageInSol',
      title: 'Image in solution',
      type: 'image',
      options: { hotspot: true },
      fields: [
        defineField({ name: 'alt', type: 'string' }),
        defineField({ name: 'caption', type: 'string' }),
      ],
    }),
    defineField({
      name: 'course',
      type: 'reference',
      to: [{ type: 'course' }],
      description: 'Course/topic this question belongs to',
    }),
    defineField({
      name: 'marks',
      type: 'number',
      initialValue: 1,
    }),
  ],
})
