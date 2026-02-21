import { DashboardOverview } from "../../design-system/organisms/DashboardOverview";
import { ClassCard } from "../../design-system/molecules/ClassCard";
import { TeacherTopBar } from "../../design-system/organisms/TeacherTopBar";

const weeklyEngagement = [
  { day: "Mon", students: 45 },
  { day: "Tue", students: 52 },
  { day: "Wed", students: 48 },
  { day: "Thu", students: 60 },
  { day: "Fri", students: 55 },
  { day: "Sat", students: 38 },
  { day: "Sun", students: 30 },
];

const recentActivity = [
  { student: "John Doe", action: "Completed Physics Chapter 3", time: "2 hours ago" },
  { student: "Emma Wilson", action: "Submitted Assignment 5", time: "3 hours ago" },
  { student: "Michael Chen", action: "Asked a question in Q&A", time: "5 hours ago" },
  { student: "Sarah Parker", action: "Watched Lecture 12", time: "1 day ago" },
  { student: "David Kumar", action: "Completed Quiz on Thermodynamics", time: "1 day ago" },
];

const myCourses = [
  {
    id: "1",
    name: "Advanced Physics",
    subject: "Physics",
    studentCount: 87,
    avgScore: 78,
    completion: 72,
  },
  {
    id: "2",
    name: "Quantum Mechanics",
    subject: "Physics",
    studentCount: 64,
    avgScore: 82,
    completion: 58,
  },
  {
    id: "3",
    name: "Thermodynamics",
    subject: "Physics",
    studentCount: 96,
    avgScore: 85,
    completion: 81,
  },
  {
    id: "4",
    name: "Classical Mechanics",
    subject: "Physics",
    studentCount: 73,
    avgScore: 76,
    completion: 65,
  },
  {
    id: "5",
    name: "Electromagnetism",
    subject: "Physics",
    studentCount: 55,
    avgScore: 80,
    completion: 70,
  },
];

const weakTopics = [
  { topic: "Newton's Laws", avgScore: 62 },
  { topic: "Quantum Entanglement", avgScore: 58 },
  { topic: "Heat Transfer", avgScore: 65 },
];

export function TeacherDashboard() {
  return (
    <div className="min-h-screen bg-background">
      {/* Top Bar */}
      <TeacherTopBar teacherName="Dr. Johnson" notificationCount={5} />

      {/* Main Content */}
      <div className="p-8">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">
              Welcome Back, Dr. Johnson
            </h1>
            <p className="text-muted-foreground">
              Here's what's happening with your courses today
            </p>
          </div>

          {/* Dashboard Overview with Stats and Charts */}
          <DashboardOverview
            stats={{
              activeCourses: 5,
              totalStudents: 247,
              avgPerformance: 85,
              pendingReviews: 12,
            }}
            weeklyData={weeklyEngagement}
            recentActivity={recentActivity}
            weakTopics={weakTopics}
          />

          {/* My Courses Section */}
          <div className="mt-8">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-semibold font-['Outfit']">My Courses</h2>
              <button className="text-sm text-primary hover:underline font-medium">
                View All →
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {myCourses.map((course) => (
                <ClassCard
                  key={course.id}
                  id={course.id}
                  name={course.name}
                  subject={course.subject}
                  studentCount={course.studentCount}
                  avgScore={course.avgScore}
                  completion={course.completion}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
