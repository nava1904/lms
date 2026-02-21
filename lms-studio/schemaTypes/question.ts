import {defineType, defineField} from 'sanity'

export default defineType({
  name: 'question',
  title: 'Question',
  type: 'document',
  fields: [
    defineField({
      name: 'questionText',
      title: 'Question Text',
      type: 'text',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'questionType',
      title: 'Question Type',
      type: 'string',
      options: {
        list: [
          {title: 'Multiple Choice', value: 'mcq'},
          {title: 'True/False', value: 'truefalse'},
          {title: 'Short Answer', value: 'short'},
          {title: 'Long Answer', value: 'long'},
          {title: 'Fill in the Blank', value: 'fillblank'},
        ],
      },
      initialValue: 'mcq',
    }),
    defineField({
      name: 'options',
      title: 'Options (for MCQ)',
      type: 'array',
      of: [{type: 'string'}],
      hidden: ({parent}) => parent?.questionType !== 'mcq',
    }),
    defineField({
      name: 'correctAnswer',
      title: 'Correct Answer',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'marks',
      title: 'Marks',
      type: 'number',
      validation: (Rule) => Rule.required().min(1),
      initialValue: 1,
    }),
    defineField({
      name: 'explanation',
      title: 'Explanation',
      type: 'text',
      description: 'Explanation shown after answering',
    }),
    defineField({
      name: 'difficulty',
      title: 'Difficulty',
      type: 'string',
      options: {
        list: [
          {title: 'Easy', value: 'easy'},
          {title: 'Medium', value: 'medium'},
          {title: 'Hard', value: 'hard'},
        ],
      },
      initialValue: 'medium',
    }),
    defineField({
      name: 'subject',
      title: 'Subject',
      type: 'reference',
      to: [{type: 'subject'}],
    }),
    defineField({
      name: 'chapter',
      title: 'Chapter',
      type: 'reference',
      to: [{type: 'chapter'}],
    }),
  ],
  preview: {
    select: {
      title: 'questionText',
      subtitle: 'questionType',
    },
  },
})
