import { useState } from "react";
import { Search, Mail, Phone, TrendingUp, Eye } from "lucide-react";
import { Input } from "../../components/ui/input";
import { Button } from "../../components/ui/button";
import { Badge } from "../../components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "../../components/ui/dialog";

interface Student {
  id: string;
  name: string;
  email: string;
  phone: string;
  course: string;
  progress: number;
  testScore: number;
  status: "active" | "inactive";
}

const students: Student[] = [
  {
    id: "1",
    name: "John Doe",
    email: "john.doe@example.com",
    phone: "+1 234-567-8901",
    course: "Advanced Physics",
    progress: 72,
    testScore: 85,
    status: "active",
  },
  {
    id: "2",
    name: "Emma Wilson",
    email: "emma.wilson@example.com",
    phone: "+1 234-567-8902",
    course: "Advanced Physics",
    progress: 88,
    testScore: 92,
    status: "active",
  },
  {
    id: "3",
    name: "Michael Chen",
    email: "michael.chen@example.com",
    phone: "+1 234-567-8903",
    course: "Quantum Mechanics",
    progress: 45,
    testScore: 78,
    status: "active",
  },
  {
    id: "4",
    name: "Sarah Parker",
    email: "sarah.parker@example.com",
    phone: "+1 234-567-8904",
    course: "Advanced Physics",
    progress: 95,
    testScore: 96,
    status: "active",
  },
];

export function StudentManagement() {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);

  const filteredStudents = students.filter(
    (student) =>
      student.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      student.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Student Management</h1>
          <p className="text-muted-foreground">View and manage enrolled students</p>
        </div>

        {/* Search Bar */}
        <div className="mb-6">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
            <Input
              placeholder="Search students by name or email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>

        {/* Students Table */}
        <div className="bg-white rounded-xl shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border overflow-hidden">
          <table className="w-full">
            <thead className="bg-accent/50">
              <tr>
                <th className="text-left p-4 font-medium">Student</th>
                <th className="text-left p-4 font-medium">Course</th>
                <th className="text-left p-4 font-medium">Progress</th>
                <th className="text-left p-4 font-medium">Test Score</th>
                <th className="text-left p-4 font-medium">Status</th>
                <th className="text-right p-4 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {filteredStudents.map((student) => (
                <tr key={student.id} className="hover:bg-accent/20">
                  <td className="p-4">
                    <div>
                      <p className="font-medium text-foreground">{student.name}</p>
                      <p className="text-sm text-muted-foreground">{student.email}</p>
                    </div>
                  </td>
                  <td className="p-4">
                    <span className="text-sm">{student.course}</span>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <div className="w-24 h-2 bg-accent rounded-full overflow-hidden">
                        <div
                          className="h-full bg-primary"
                          style={{ width: `${student.progress}%` }}
                        ></div>
                      </div>
                      <span className="text-sm font-medium">{student.progress}%</span>
                    </div>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <span className="text-lg font-semibold text-primary font-['Outfit']">
                        {student.testScore}%
                      </span>
                      <TrendingUp className="w-4 h-4 text-green-600" />
                    </div>
                  </td>
                  <td className="p-4">
                    <Badge
                      variant={student.status === "active" ? "default" : "secondary"}
                      className={
                        student.status === "active"
                          ? "bg-green-100 text-green-700 hover:bg-green-100"
                          : ""
                      }
                    >
                      {student.status}
                    </Badge>
                  </td>
                  <td className="p-4">
                    <div className="flex justify-end gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setSelectedStudent(student)}
                      >
                        <Eye className="w-4 h-4 mr-2" />
                        View Details
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Student Details Dialog */}
        <Dialog open={!!selectedStudent} onOpenChange={() => setSelectedStudent(null)}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Student Details</DialogTitle>
            </DialogHeader>
            {selectedStudent && (
              <div className="space-y-6">
                {/* Basic Info */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Name</p>
                    <p className="font-medium">{selectedStudent.name}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Status</p>
                    <Badge
                      variant={selectedStudent.status === "active" ? "default" : "secondary"}
                      className={
                        selectedStudent.status === "active"
                          ? "bg-green-100 text-green-700 hover:bg-green-100"
                          : ""
                      }
                    >
                      {selectedStudent.status}
                    </Badge>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Email</p>
                    <p className="font-medium flex items-center gap-2">
                      <Mail className="w-4 h-4" />
                      {selectedStudent.email}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Phone</p>
                    <p className="font-medium flex items-center gap-2">
                      <Phone className="w-4 h-4" />
                      {selectedStudent.phone}
                    </p>
                  </div>
                </div>

                {/* Performance Stats */}
                <div>
                  <h3 className="font-semibold mb-4 font-['Outfit']">Performance Overview</h3>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="p-4 bg-accent/50 rounded-lg">
                      <p className="text-sm text-muted-foreground mb-1">Course Progress</p>
                      <p className="text-2xl font-bold text-primary font-['Outfit']">
                        {selectedStudent.progress}%
                      </p>
                    </div>
                    <div className="p-4 bg-accent/50 rounded-lg">
                      <p className="text-sm text-muted-foreground mb-1">Test Score</p>
                      <p className="text-2xl font-bold text-green-600 font-['Outfit']">
                        {selectedStudent.testScore}%
                      </p>
                    </div>
                  </div>
                </div>

                {/* Enrolled Course */}
                <div>
                  <h3 className="font-semibold mb-2 font-['Outfit']">Enrolled Course</h3>
                  <div className="p-4 border border-border rounded-lg">
                    <p className="font-medium">{selectedStudent.course}</p>
                  </div>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
