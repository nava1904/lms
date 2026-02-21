import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'admin',
  title: 'Admin',
  type: 'document',
  fields: [
    defineField({
      name: 'name',
      title: 'Full Name',
      type: 'string',
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: 'email',
      title: 'Email',
      type: 'string',
      validation: (Rule) => Rule.required().email(),
    }),
    defineField({
      name: 'role',
      title: 'Admin Role',
      type: 'string',
      options: {
        list: [
          { title: 'Super Admin', value: 'super_admin' },
          { title: 'Content Manager', value: 'content_manager' },
          { title: 'User Manager', value: 'user_manager' },
          { title: 'Analytics Viewer', value: 'analytics_viewer' },
        ],
      },
      initialValue: 'content_manager',
    }),
    defineField({
      name: 'permissions',
      title: 'Permissions',
      type: 'array',
      of: [{ type: 'string' }],
      options: {
        list: [
          { title: 'Manage Users', value: 'manage_users' },
          { title: 'Manage Content', value: 'manage_content' },
          { title: 'Manage Tests', value: 'manage_tests' },
          { title: 'View Analytics', value: 'view_analytics' },
          { title: 'Manage Settings', value: 'manage_settings' },
        ],
      },
    }),
    defineField({
      name: 'profileImage',
      title: 'Profile Image',
      type: 'image',
      options: {
        hotspot: true,
      },
    }),
    defineField({
      name: 'isActive',
      title: 'Is Active',
      type: 'boolean',
      initialValue: true,
    }),
  ],
  preview: {
    select: {
      title: 'name',
      subtitle: 'role',
      media: 'profileImage',
    },
  },
})
