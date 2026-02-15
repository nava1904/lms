import { defineType, defineField } from 'sanity'
import { UserIcon } from '@sanity/icons'

export const admin = defineType({
  name: 'admin',
  title: 'Admin',
  type: 'document',
  icon: UserIcon,
  fields: [
    defineField({
      name: 'name',
      type: 'string',
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'email',
      type: 'string',
      validation: (rule) => rule.email().required(),
      title: 'Email',
    }),
    defineField({
      name: 'phone',
      type: 'string',
      title: 'Phone Number',
    }),
    defineField({
      name: 'role',
      type: 'string',
      options: {
        list: [
          { title: 'Super Admin', value: 'super_admin' },
          { title: 'Management', value: 'management' },
          { title: 'HR', value: 'hr' },
        ],
      },
      validation: (rule) => rule.required(),
    }),
    defineField({
      name: 'permissions',
      type: 'array',
      of: [{ type: 'string' }],
      options: {
        list: [
          { title: 'Manage Students', value: 'manage_students' },
          { title: 'Manage Teachers', value: 'manage_teachers' },
          { title: 'Manage Attendance', value: 'manage_attendance' },
          { title: 'Manage Tests', value: 'manage_tests' },
          { title: 'View Analytics', value: 'view_analytics' },
          { title: 'View Content', value: 'view_content' },
        ],
      },
    }),
    defineField({
      name: 'createdAt',
      type: 'datetime',
    }),
  ],
})
