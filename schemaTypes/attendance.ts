import { defineType, defineField } from 'sanity'
import { CalendarIcon } from '@sanity/icons'

export const attendance = defineType({
  name: 'attendance',
  title: 'Attendance',
  type: 'document',
  icon: CalendarIcon,
  fields: [
    defineField({
      name: 'student',
      type: 'reference',
      to: [{ type: 'student' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'subject',
      type: 'reference',
      to: [{ type: 'subject' }],
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'date',
      type: 'date',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'status',
      type: 'string',
      options: {
        list: [
          { title: 'Present', value: 'present' },
          { title: 'Absent', value: 'absent' },
          { title: 'Leave', value: 'leave' },
        ],
      },
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'remarks',
      type: 'text',
      title: 'Remarks',
    }),
  ],
})

export const adBanner = {
  name: 'adBanner',
  type: 'document',
  title: 'Ad Banner',
  fields: [
    { name: 'headline', type: 'string', title: 'Headline' },
    { name: 'image', type: 'image', title: 'Image' },
    { name: 'callToAction', type: 'url', title: 'Call To Action' },
  ],
}
