import { Users, FileText, BookOpen, BarChart3, ArrowLeft } from "lucide-react";
import { useNavigate, useParams } from "react-router";
import { TeacherTopBar } from "../../design-system/organisms/TeacherTopBar";
import { ClassDetailTabs, StudentsTabContent, WorksheetsTabContent } from "../../design-system/organisms/ClassDetailTabs";
import { StudentRow } from "../../design-system/molecules/StudentRow";
import { WorksheetCard } from "../../design-system/molecules/WorksheetCard";
import { Button } from "../../components/ui/button";
import { useState } from "react";
import { StudentAnalyticsDrawer } from "../../design-system/organisms/StudentAnalyticsDrawer";

// Mock class data
const classData = {
  id: "1",
  name: "Advanced Physics",
  subject: "Physics",
  studentCount: 87,
  avgScore: 78,
  completion: 72,
};

const classStudents = [
  {
    id: "1",
    name: "John Doe",
    email: "john.doe@example.com",
    avgScore: 85,
    completion: 72,
    riskLevel: "low" as const,
    totalTimeSpent: "24h",
  },
  {
    id: "2",
    name: "Emma Wilson",
    email: "emma.wilson@example.com",
    avgScore: 92,
    completion: 88,
    riskLevel: "low" as const,
    totalTimeSpent: "32h",
  },
  {
    id: "3",
    name: "Michael Chen",
    email: "michael.chen@example.com",
    avgScore: 58,
    completion: 45,
    riskLevel: "high" as const,
    totalTimeSpent: "12h",
  },
];

const classWorksheets = [
  {
    id: "1",
    title: "Newton's Laws Practice Quiz",
    assignedTo: "All Students",
    dueDate: "Feb 25, 2026",
    submissionCount: 65,
    totalStudents: 87,
    avgScore: 82,
    status: "active" as const,
  },
  {
    id: "2",
    title: "Midterm Examination",
    assignedTo: "All Students",
    dueDate: "Mar 5, 2026",
    submissionCount: 12,
    totalStudents: 87,
    avgScore: 78,
    status: "active" as const,
  },
  {
    id: "3",
    title: "Final Project Assignment",
    assignedTo: "All Students",
    dueDate: "Mar 20, 2026",
    submissionCount: 0,
    totalStudents: 87,
    status: "draft" as const,
  },
];

const getStudentPerformanceData = (studentId: string) => [
  { week: "Week 1", score: 75 },
  { week: "Week 2", score: 78 },
  { week: "Week 3", score: 82 },
  { week: "Week 4", score: 85 },
  { week: "Week 5", score: 88 },
  { week: "Week 6", score: 85 },
];

const getStudentWeakTopics = (studentId: string) => [
  { topic: "Newton's Laws", score: 62 },
  { topic: "Quantum Entanglement", score: 58 },
  { topic: "Wave Mechanics", score: 65 },
];

const getStudentWorksheetAttempts = (studentId: string) => [
  { name: "Physics Quiz #5", score: 88, date: "2 days ago" },
  { name: "Thermodynamics Test", score: 92, date: "5 days ago" },
  { name: "Practice Problems Set 3", score: 76, date: "1 week ago" },
];

export function ClassDetail() {
  const navigate = useNavigate();
  const { classId } = useParams();
  const [selectedStudent, setSelectedStudent] = useState<any | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  const handleViewStudent = (studentId: string) => {
    const student = classStudents.find((s) => s.id === studentId);
    if (student) {
      setSelectedStudent(student);
      setIsDrawerOpen(true);
    }
  };

  const tabs = [
    {
      id: "students",
      label: "Students",
      icon: Users,
      content: (
        <StudentsTabContent>
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm text-muted-foreground">
              {classStudents.length} students enrolled
            </p>
            <Button variant="outline" size="sm">
              Add Student
            </Button>
          </div>
          {classStudents.map((student) => (
            <StudentRow
              key={student.id}
              {...student}
              onViewDetails={handleViewStudent}
            />
          ))}
        </StudentsTabContent>
      ),
    },
    {
      id: "worksheets",
      label: "Worksheets",
      icon: FileText,
      content: (
        <WorksheetsTabContent>
          <div className="col-span-full flex items-center justify-between mb-2">
            <p className="text-sm text-muted-foreground">
              {classWorksheets.length} worksheets assigned
            </p>
            <Button 
              className="bg-primary"
              onClick={() => navigate("/teacher/create-worksheet")}
            >
              Create Worksheet
            </Button>
          </div>
          {classWorksheets.map((worksheet) => (
            <WorksheetCard key={worksheet.id} {...worksheet} />
          ))}
        </WorksheetsTabContent>
      ),
    },
    {
      id: "content",
      label: "Content",
      icon: BookOpen,
      content: (
        <div className="space-y-4">
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm text-muted-foreground">Course materials and resources</p>
            <Button variant="outline" size="sm">
              Upload Content
            </Button>
          </div>
          <div className="bg-accent/30 rounded-lg p-8 text-center border-2 border-dashed border-border">
            <BookOpen className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
            <p className="text-muted-foreground">No content uploaded yet</p>
            <p className="text-sm text-muted-foreground mt-1">
              Upload videos, documents, and other learning materials
            </p>
          </div>
        </div>
      ),
    },
    {
      id: "analytics",
      label: "Analytics",
      icon: BarChart3,
      content: (
        <div className="space-y-6">
          <div className="grid grid-cols-3 gap-6">
            <div className="bg-blue-50 rounded-xl p-6 border border-blue-100">
              <p className="text-sm text-blue-600 mb-1">Average Score</p>
              <p className="text-3xl font-bold text-blue-700 font-['Outfit']">{classData.avgScore}%</p>
            </div>
            <div className="bg-emerald-50 rounded-xl p-6 border border-emerald-100">
              <p className="text-sm text-emerald-600 mb-1">Completion Rate</p>
              <p className="text-3xl font-bold text-emerald-700 font-['Outfit']">{classData.completion}%</p>
            </div>
            <div className="bg-purple-50 rounded-xl p-6 border border-purple-100">
              <p className="text-sm text-purple-600 mb-1">Active Students</p>
              <p className="text-3xl font-bold text-purple-700 font-['Outfit']">{classData.studentCount}</p>
            </div>
          </div>
          <div className="bg-accent/30 rounded-lg p-8 text-center">
            <BarChart3 className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
            <p className="text-muted-foreground">Detailed analytics coming soon</p>
          </div>
        </div>
      ),
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <TeacherTopBar teacherName="Dr. Johnson" notificationCount={5} />

      <div className="p-8">
        <div className="max-w-7xl mx-auto">
          {/* Back Button */}
          <button
            onClick={() => navigate("/teacher/courses")}
            className="flex items-center gap-2 text-sm text-primary hover:underline mb-6 font-medium"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Courses
          </button>

          {/* Class Header */}
          <div className="bg-white rounded-xl p-8 shadow-[0_2px_8px_rgba(0,0,0,0.04)] border border-border mb-8">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-3 mb-2">
                  <h1 className="text-4xl font-bold text-foreground font-['Outfit']">
                    {classData.name}
                  </h1>
                  <span className="bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-medium">
                    {classData.subject}
                  </span>
                </div>
                <div className="flex items-center gap-6 text-muted-foreground">
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4" />
                    <span>{classData.studentCount} students</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <BarChart3 className="w-4 h-4" />
                    <span>Avg Score: {classData.avgScore}%</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <FileText className="w-4 h-4" />
                    <span>{classWorksheets.length} worksheets</span>
                  </div>
                </div>
              </div>
              <Button size="lg" className="bg-primary">
                Manage Class
              </Button>
            </div>
          </div>

          {/* Tabs */}
          <ClassDetailTabs tabs={tabs} defaultTab="students" />
        </div>
      </div>

      {/* Student Analytics Drawer */}
      {selectedStudent && (
        <StudentAnalyticsDrawer
          isOpen={isDrawerOpen}
          onClose={() => {
            setIsDrawerOpen(false);
            setSelectedStudent(null);
          }}
          student={selectedStudent}
          performanceData={getStudentPerformanceData(selectedStudent.id)}
          weakTopics={getStudentWeakTopics(selectedStudent.id)}
          worksheetAttempts={getStudentWorksheetAttempts(selectedStudent.id)}
        />
      )}
    </div>
  );
}