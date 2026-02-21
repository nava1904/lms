import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'adBanner',
  title: 'Ad / Marketing Banner',
  type: 'document',
  fields: [
    defineField({
      name: 'headline',
      title: 'Headline',
      type: 'string',
    }),
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
    }),
    defineField({
      name: 'image',
      title: 'Image',
      type: 'image',
      options: { hotspot: true },
    }),
    defineField({
      name: 'callToAction',
      title: 'Call to Action',
      type: 'string',
      description: 'Button or link text (e.g. "Join Now")',
    }),
    defineField({
      name: 'active',
      title: 'Active',
      type: 'boolean',
      initialValue: true,
    }),
  ],
  preview: {
    select: { headline: 'headline', active: 'active' },
    prepare: ({ headline, active }) => ({
      title: headline || 'Banner',
      subtitle: active ? 'Active' : 'Inactive',
    }),
  },
})
