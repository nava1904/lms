import { useState } from "react";
import { Search, Filter } from "lucide-react";
import { Input } from "../../components/ui/input";
import { Button } from "../../components/ui/button";
import { TeacherTopBar } from "../../design-system/organisms/TeacherTopBar";
import { StudentRow } from "../../design-system/molecules/StudentRow";
import { StudentAnalyticsDrawer } from "../../design-system/organisms/StudentAnalyticsDrawer";

interface Student {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  course: string;
  avgScore: number;
  completion: number;
  riskLevel?: "low" | "medium" | "high";
  totalTimeSpent: string;
}

const students: Student[] = [
  {
    id: "1",
    name: "John Doe",
    email: "john.doe@example.com",
    course: "Advanced Physics",
    avgScore: 85,
    completion: 72,
    riskLevel: "low",
    totalTimeSpent: "24h",
  },
  {
    id: "2",
    name: "Emma Wilson",
    email: "emma.wilson@example.com",
    course: "Advanced Physics",
    avgScore: 92,
    completion: 88,
    riskLevel: "low",
    totalTimeSpent: "32h",
  },
  {
    id: "3",
    name: "Michael Chen",
    email: "michael.chen@example.com",
    course: "Quantum Mechanics",
    avgScore: 58,
    completion: 45,
    riskLevel: "high",
    totalTimeSpent: "12h",
  },
  {
    id: "4",
    name: "Sarah Parker",
    email: "sarah.parker@example.com",
    course: "Advanced Physics",
    avgScore: 96,
    completion: 95,
    riskLevel: "low",
    totalTimeSpent: "38h",
  },
  {
    id: "5",
    name: "David Kumar",
    email: "david.kumar@example.com",
    course: "Thermodynamics",
    avgScore: 68,
    completion: 62,
    riskLevel: "medium",
    totalTimeSpent: "18h",
  },
  {
    id: "6",
    name: "Lisa Anderson",
    email: "lisa.anderson@example.com",
    course: "Quantum Mechanics",
    avgScore: 78,
    completion: 70,
    riskLevel: "low",
    totalTimeSpent: "26h",
  },
];

// Mock data for student analytics
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
  { name: "Midterm Exam", score: 85, date: "2 weeks ago" },
];

export function StudentManagement() {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  const filteredStudents = students.filter(
    (student) =>
      student.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      student.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      student.course.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleViewDetails = (studentId: string) => {
    const student = students.find((s) => s.id === studentId);
    if (student) {
      setSelectedStudent(student);
      setIsDrawerOpen(true);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <TeacherTopBar teacherName="Dr. Johnson" notificationCount={5} />

      <div className="p-8">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">
              Student Management
            </h1>
            <p className="text-muted-foreground">
              View and manage student performance across all courses
            </p>
          </div>

          {/* Search & Filter Bar */}
          <div className="flex items-center gap-4 mb-6">
            <div className="relative flex-1 max-w-lg">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <Input
                placeholder="Search students by name, email, or course..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 bg-white"
              />
            </div>
            <Button variant="outline" className="gap-2">
              <Filter className="w-4 h-4" />
              Filters
            </Button>
          </div>

          {/* Student Count */}
          <div className="mb-4">
            <p className="text-sm text-muted-foreground">
              Showing {filteredStudents.length} of {students.length} students
            </p>
          </div>

          {/* Students List */}
          <div className="space-y-3">
            {filteredStudents.map((student) => (
              <StudentRow
                key={student.id}
                id={student.id}
                name={student.name}
                email={student.email}
                avatar={student.avatar}
                avgScore={student.avgScore}
                completion={student.completion}
                riskLevel={student.riskLevel}
                onViewDetails={handleViewDetails}
              />
            ))}
          </div>

          {/* Empty State */}
          {filteredStudents.length === 0 && (
            <div className="bg-white rounded-xl border border-border p-12 text-center">
              <p className="text-muted-foreground">No students found matching your search.</p>
            </div>
          )}
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
