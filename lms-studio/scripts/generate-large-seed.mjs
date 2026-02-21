#!/usr/bin/env node
/**
 * Generates seed-large.json: stress dataset with 100+ concepts,
 * teachers with full profiles (subjects teaching, etc.), tests with all schema fields.
 * Run: node scripts/generate-large-seed.mjs > seed-large.json
 */

function slug(s) {
  return String(s).toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

function block(text, key) {
  return { _type: 'block', _key: key, style: 'normal', children: [{ _type: 'span', _key: 's1', text }], markDefs: [] };
}

function ref(id) {
  return { _type: 'reference', _ref: id };
}

const lines = [];

function emit(obj) {
  lines.push(JSON.stringify(obj));
}

// --- COURSES (5)
const courses = [
  { id: 'course-1', title: 'JEE Physics Foundation', slug: 'jee-physics-foundation', description: 'Complete Physics for JEE. Mechanics, Thermodynamics, Waves.', level: 'intermediate', duration: 120, order: 0 },
  { id: 'course-2', title: 'Class 11 Physics Basics', slug: 'class-11-physics-basics', description: 'Foundation physics for class 11.', level: 'beginner', duration: 60, order: 1 },
  { id: 'course-3', title: 'NEET Biology Core', slug: 'neet-biology-core', description: 'Botany and Zoology for NEET.', level: 'intermediate', duration: 100, order: 2 },
  { id: 'course-4', title: 'JEE Chemistry', slug: 'jee-chemistry', description: 'Physical, Organic, Inorganic Chemistry.', level: 'intermediate', duration: 90, order: 3 },
  { id: 'course-5', title: 'Class 12 Mathematics', slug: 'class-12-mathematics', description: 'Calculus, Algebra, Vectors.', level: 'advanced', duration: 80, order: 4 },
];
courses.forEach((c) => emit({ _id: c.id, _type: 'course', title: c.title, slug: { _type: 'slug', current: c.slug }, description: c.description, level: c.level, duration: c.duration, order: c.order }));

// --- SUBJECTS (15: 3 per course)
const subjects = [];
let sid = 1;
courses.forEach((course, ci) => {
  const titles = [
    ['Mechanics', 'Thermodynamics', 'Waves'],
    ['Kinematics', 'Dynamics', 'Optics'],
    ['Botany', 'Zoology', 'Human Physiology'],
    ['Physical Chemistry', 'Organic Chemistry', 'Inorganic Chemistry'],
    ['Calculus', 'Algebra', 'Vectors'],
  ][ci];
  titles.forEach((title, i) => {
    const id = `subject-${sid}`;
    subjects.push({ id, title, slug: slug(title), description: `${title} topics.`, courseId: course.id, order: i });
    emit({ _id: id, _type: 'subject', title, slug: { _type: 'slug', current: slug(title) }, description: `${title} topics.`, course: ref(course.id), order: i });
    sid++;
  });
});

// --- CHAPTERS (~50: 3–4 per subject)
const chapters = [];
let cid = 1;
subjects.forEach((subj, si) => {
  const nCh = si < 5 ? 4 : 3;
  for (let i = 0; i < nCh; i++) {
    const title = `${subj.title} Part ${i + 1}`;
    const id = `chapter-${cid}`;
    chapters.push({ id, title, subjectId: subj.id, order: i });
    emit({ _id: id, _type: 'chapter', title, slug: { _type: 'slug', current: slug(title) }, subject: ref(subj.id), order: i });
    cid++;
  }
});

// --- CONCEPTS (120+): 2–3 per chapter
const concepts = [];
let conceptId = 1;
const conceptTitles = [
  'Introduction and definitions', 'Core formula', 'Derivation', 'Examples', 'Applications', 'Summary', 'Key points', 'Practice tips',
  'Theory overview', 'Step-by-step method', 'Common mistakes', 'Advanced topic', 'Revision notes', 'Quick recap', 'Deep dive',
];
chapters.forEach((ch, i) => {
  const n = i % 3 === 0 ? 3 : 2;
  for (let j = 0; j < n; j++) {
    const title = `${ch.title} – ${conceptTitles[(conceptId - 1) % conceptTitles.length]}`;
    const id = `concept-${conceptId}`;
    const content = `Content for ${title}. This is placeholder text for stress testing the LMS.`;
    concepts.push({ id, title, chapterId: ch.id, order: j });
    emit({
      _id: id,
      _type: 'concept',
      title,
      slug: { _type: 'slug', current: slug(title).slice(0, 90) },
      chapter: ref(ch.id),
      content: [block(content, `c${conceptId}`)],
      duration: 5 + (conceptId % 10),
      order: j,
    });
    conceptId++;
  }
});

// --- ASSIGNMENTS (one per chapter)
chapters.forEach((ch, i) => {
  const id = `assignment-${i + 1}`;
  const subj = subjects.find((s) => s.id === ch.subjectId);
  if (!subj) return;
  emit({
    _id: id,
    _type: 'assignment',
    title: `Assignment: ${ch.title}`,
    chapter: ref(ch.id),
    subject: ref(subj.id),
    description: [block(`Complete problems from ${ch.title}. Submit before due date.`, `a${i + 1}`)],
    maxScore: 100,
    isPublished: true,
  });
});

// --- QUESTIONS (60 MCQs): 4 per subject for tests
const questions = [];
let qid = 1;
const mcqTemplates = [
  { q: 'What is the main topic of %s?', opts: ['Topic A', 'Topic B', 'Topic C', 'Topic D'], correct: 'Topic A' },
  { q: 'Unit of measurement in %s is:', opts: ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4'], correct: 'Unit 1' },
  { q: 'Formula related to %s:', opts: ['F = ma', 'E = mc²', 'v = fλ', 'PV = nRT'], correct: 'F = ma' },
  { q: '%s is important for:', opts: ['Exams', 'Applications', 'Research', 'All'], correct: 'All' },
];
subjects.forEach((subj) => {
  const ch = chapters.find((c) => c.subjectId === subj.id);
  if (!ch) return;
  for (let k = 0; k < 4; k++) {
    const t = mcqTemplates[k % mcqTemplates.length];
    const id = `q${qid}`;
    questions.push({ id, subjectId: subj.id, chapterId: ch.id });
    emit({
      _id: id,
      _type: 'question',
      questionText: t.q.replace('%s', subj.title),
      questionType: 'mcq',
      options: t.opts,
      correctAnswer: t.correct,
      marks: 5,
      subject: ref(subj.id),
      chapter: ref(ch.id),
      explanation: `Correct answer: ${t.correct}.`,
      difficulty: k % 3 === 0 ? 'easy' : k % 3 === 1 ? 'medium' : 'hard',
    });
    qid++;
  }
});

// --- TESTS (15): one per subject, all schema fields
subjects.forEach((subj, i) => {
  const ch = chapters.find((c) => c.subjectId === subj.id);
  if (!ch) return;
  const subjQuestions = questions.filter((q) => q.subjectId === subj.id).slice(0, 5);
  if (subjQuestions.length === 0) return;
  const totalMarks = subjQuestions.length * 5;
  const passingMarks = Math.floor(totalMarks * 0.4);
  const id = `test-${i + 1}`;
  emit({
    _id: id,
    _type: 'test',
    title: `${subj.title} Quiz`,
    description: `Quiz covering key concepts in ${subj.title}. Answer all questions. Each question carries 5 marks.`,
    subject: ref(subj.id),
    chapter: ref(ch.id),
    duration: 20,
    totalMarks,
    passingMarks,
    questions: subjQuestions.map((q) => ref(q.id)),
    instructions: [block(`Select one answer per question. No negative marking. Time limit: 20 minutes. Passing marks: ${passingMarks}.`, `inst${i + 1}`)],
    isPublished: true,
    scheduledFor: i % 2 === 0 ? '2026-03-01T10:00:00.000Z' : undefined,
  });
});

// --- ADMIN
emit({ _id: 'admin-1', _type: 'admin', name: 'Super Admin', email: 'admin@lms.com', role: 'super_admin', isActive: true });

// --- TEACHERS (3) with full profiles: subjects, specialization, qualification, phone, bio
const teacherSubjects = [
  subjects.filter((_, i) => i < 5).map((s) => s.id),   // course-1 + course-2 physics
  subjects.filter((_, i) => i >= 5 && i < 10).map((s) => s.id),
  subjects.filter((_, i) => i >= 10).map((s) => s.id),
];
const teachers = [
  { id: 'teacher-1', name: 'Dr Ravi Kumar', email: 'ravi@lms.com', phone: '+91-9876543210', specialization: 'Mechanics and Thermodynamics', qualification: 'PhD Physics, IIT', bio: 'Senior faculty for JEE Physics. 15+ years teaching experience.', subIds: teacherSubjects[0] },
  { id: 'teacher-2', name: 'Ms Sneha Iyer', email: 'sneha@lms.com', phone: '+91-9876543211', specialization: 'Kinematics and Waves', qualification: 'MSc Physics, BEd', bio: 'Class 11–12 Physics. Focus on foundations.', subIds: teacherSubjects[1] },
  { id: 'teacher-3', name: 'Dr Amit Sharma', email: 'amit@lms.com', phone: '+91-9876543212', specialization: 'Biology and Chemistry', qualification: 'PhD Life Sciences, AIIMS', bio: 'NEET and JEE Chemistry/Biology. Author of two textbooks.', subIds: teacherSubjects[2] },
];
teachers.forEach((t) => {
  emit({
    _id: t.id,
    _type: 'teacher',
    name: t.name,
    email: t.email,
    phone: t.phone,
    specialization: t.specialization,
    qualification: t.qualification,
    subjects: t.subIds.map((id) => ref(id)),
    bio: t.bio,
    isActive: true,
  });
});

// --- STUDENTS (20) with enrolled courses
const studentNames = ['Arjun Reddy', 'Aditi Rao', 'Rahul Verma', 'Karthik Sai', 'Sneha Sharma', 'Vikram Das', 'Meera Joshi', 'Rohan Mehta', 'Ishita Singh', 'Ananya Gupta', 'Varun Nair', 'Priya Patel', 'Dev Khanna', 'Kavya Menon', 'Arun Singh', 'Neha Reddy', 'Rishabh Gupta', 'Pooja Iyer', 'Akash Joshi', 'Divya Nair'];
studentNames.forEach((name, i) => {
  const id = `student-${i + 1}`;
  const roll = `ROLL${String(i + 1).padStart(3, '0')}`;
  const courseRefs = [ref('course-1'), ref('course-2')];
  if (i % 3 === 0) courseRefs.push(ref('course-3'));
  if (i % 4 === 0) courseRefs.push(ref('course-4'));
  emit({ _id: id, _type: 'student', name, email: `student${i + 1}@test.com`, rollNumber: roll, enrolledCourses: courseRefs, isActive: true });
});

// --- BANNER
emit({ _id: 'banner-1', _type: 'adBanner', headline: 'JEE Crash Course 2026', description: 'Enroll now and boost your AIR rank.', callToAction: 'Join Now', active: true });

process.stdout.write(lines.join('\n'));
// Stats go to stderr only; do not use 2>&1 when redirecting or the file will be corrupted
if (process.stderr.isTTY) process.stderr.write(`Generated ${lines.length} documents (${concepts.length} concepts, ${chapters.length} chapters, ${questions.length} questions, ${teachers.length} teachers)\n`);
