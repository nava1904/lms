#!/usr/bin/env node
/**
 * Seed script for LMS Sanity dataset.
 * Usage: SANITY_TOKEN=your_token node scripts/seed.mjs
 * Creates sample course and student so the Flutter app has data to display.
 */
const PROJECT_ID = 'w18438cu'
const DATASET = 'production'
const token = process.env.SANITY_TOKEN
if (!token) {
  console.error('Set SANITY_TOKEN to a write token')
  process.exit(1)
}

const url = `https://${PROJECT_ID}.api.sanity.io/v2024-01-01/data/mutate/${DATASET}`

async function mutate(mutations) {
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ mutations }),
  })
  if (!res.ok) {
    const text = await res.text()
    throw new Error(`Sanity mutate failed: ${res.status} ${text}`)
  }
  return res.json()
}

async function main() {
  const courseId = 'course-seed-1'
  const studentId = 'student-seed-1'
  console.log('Creating seed course and student...')
  await mutate([
    {
      create: {
        _type: 'course',
        _id: courseId,
        title: 'JEE Advanced 2024',
        description: 'Complete course for JEE Advanced preparation',
        level: 'advanced',
      },
    },
    {
      create: {
        _type: 'student',
        _id: studentId,
        name: 'Rahul Demo',
        email: 'rahul.demo@example.com',
        rollNumber: '1001',
        enrolledCourses: [{ _type: 'reference', _ref: courseId }],
        isActive: true,
      },
    },
  ])
  console.log('Done. Course:', courseId, 'Student:', studentId)
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
