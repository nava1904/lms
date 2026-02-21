import { useState } from "react";
import { Plus, Eye, FileText, Download, Upload, Trash2 } from "lucide-react";
import { Button } from "../../components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "../../components/ui/dialog";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Badge } from "../../components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../../components/ui/tabs";

interface Student {
  id: string;
  name: string;
  email: string;
  phone: string;
  studentId: string;
  courses: string[];
  status: "active" | "inactive";
  documents: {
    name: string;
    type: string;
    uploadedDate: string;
  }[];
}

const initialStudents: Student[] = [
  {
    id: "1",
    name: "John Doe",
    email: "john.doe@student.com",
    phone: "+1 234-567-8901",
    studentId: "STU001",
    courses: ["Physics", "Mathematics"],
    status: "active",
    documents: [
      { name: "Student ID Card.pdf", type: "ID", uploadedDate: "2026-01-15" },
      { name: "Transcript.pdf", type: "Academic", uploadedDate: "2026-01-20" },
    ],
  },
  {
    id: "2",
    name: "Emma Wilson",
    email: "emma.wilson@student.com",
    phone: "+1 234-567-8902",
    studentId: "STU002",
    courses: ["Physics", "Chemistry"],
    status: "active",
    documents: [
      { name: "Student ID Card.pdf", type: "ID", uploadedDate: "2026-01-18" },
    ],
  },
];

export function StudentManagement() {
  const [students, setStudents] = useState<Student[]>(initialStudents);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [newStudent, setNewStudent] = useState({
    name: "",
    email: "",
    phone: "",
    password: "",
  });

  const generateStudentId = () => {
    const num = students.length + 1;
    return `STU${num.toString().padStart(3, "0")}`;
  };

  const handleAddStudent = () => {
    const student: Student = {
      id: Date.now().toString(),
      name: newStudent.name,
      email: newStudent.email,
      phone: newStudent.phone,
      studentId: generateStudentId(),
      courses: [],
      status: "active",
      documents: [],
    };

    setStudents([...students, student]);
    setNewStudent({ name: "", email: "", phone: "", password: "" });
    setIsAddDialogOpen(false);
  };

  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Student Management</h1>
            <p className="text-muted-foreground">Manage student accounts and documents</p>
          </div>
          <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
            <DialogTrigger asChild>
              <Button className="bg-primary hover:bg-primary/90">
                <Plus className="w-4 h-4 mr-2" />
                Add Student
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Add New Student</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 mt-4">
                <div>
                  <Label htmlFor="student-name">Full Name</Label>
                  <Input
                    id="student-name"
                    value={newStudent.name}
                    onChange={(e) => setNewStudent({ ...newStudent, name: e.target.value })}
                    placeholder="John Doe"
                  />
                </div>
                <div>
                  <Label htmlFor="student-email">Email</Label>
                  <Input
                    id="student-email"
                    type="email"
                    value={newStudent.email}
                    onChange={(e) => setNewStudent({ ...newStudent, email: e.target.value })}
                    placeholder="student@example.com"
                  />
                </div>
                <div>
                  <Label htmlFor="student-phone">Phone</Label>
                  <Input
                    id="student-phone"
                    value={newStudent.phone}
                    onChange={(e) => setNewStudent({ ...newStudent, phone: e.target.value })}
                    placeholder="+1 234-567-8900"
                  />
                </div>
                <div>
                  <Label htmlFor="student-password">Initial Password</Label>
                  <Input
                    id="student-password"
                    type="password"
                    value={newStudent.password}
                    onChange={(e) => setNewStudent({ ...newStudent, password: e.target.value })}
                    placeholder="Create a secure password"
                  />
                </div>
                <div className="bg-accent/50 p-3 rounded-lg">
                  <p className="text-sm text-muted-foreground">
                    Student ID: <span className="font-mono font-medium text-foreground">{generateStudentId()}</span>
                  </p>
                </div>
                <Button onClick={handleAddStudent} className="w-full bg-primary hover:bg-primary/90">
                  Create Student Account
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>

        {/* Students Table */}
        <div className="bg-white rounded-xl shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border overflow-hidden">
          <table className="w-full">
            <thead className="bg-accent/50">
              <tr>
                <th className="text-left p-4 font-medium">Student ID</th>
                <th className="text-left p-4 font-medium">Name</th>
                <th className="text-left p-4 font-medium">Email</th>
                <th className="text-left p-4 font-medium">Courses</th>
                <th className="text-left p-4 font-medium">Documents</th>
                <th className="text-left p-4 font-medium">Status</th>
                <th className="text-right p-4 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {students.map((student) => (
                <tr key={student.id} className="hover:bg-accent/20">
                  <td className="p-4">
                    <span className="font-mono text-sm font-medium">{student.studentId}</span>
                  </td>
                  <td className="p-4">
                    <p className="font-medium text-foreground">{student.name}</p>
                    <p className="text-sm text-muted-foreground">{student.phone}</p>
                  </td>
                  <td className="p-4">
                    <p className="text-sm">{student.email}</p>
                  </td>
                  <td className="p-4">
                    <div className="flex gap-1 flex-wrap">
                      {student.courses.length > 0 ? (
                        student.courses.map((course, idx) => (
                          <Badge key={idx} variant="outline" className="text-xs">
                            {course}
                          </Badge>
                        ))
                      ) : (
                        <span className="text-sm text-muted-foreground">None</span>
                      )}
                    </div>
                  </td>
                  <td className="p-4">
                    <div className="flex items-center gap-2">
                      <FileText className="w-4 h-4 text-muted-foreground" />
                      <span className="text-sm">{student.documents.length} files</span>
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
                      <Button variant="ghost" size="sm" onClick={() => setSelectedStudent(student)}>
                        <Eye className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="sm">
                        <Trash2 className="w-4 h-4 text-destructive" />
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
          <DialogContent className="max-w-3xl">
            <DialogHeader>
              <DialogTitle>Student Details - {selectedStudent?.name}</DialogTitle>
            </DialogHeader>
            {selectedStudent && (
              <Tabs defaultValue="info" className="w-full">
                <TabsList>
                  <TabsTrigger value="info">Information</TabsTrigger>
                  <TabsTrigger value="documents">Documents</TabsTrigger>
                </TabsList>
                <TabsContent value="info" className="space-y-4 mt-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm text-muted-foreground mb-1">Student ID</p>
                      <p className="font-mono font-medium">{selectedStudent.studentId}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground mb-1">Status</p>
                      <Badge className="bg-green-100 text-green-700">
                        {selectedStudent.status}
                      </Badge>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground mb-1">Email</p>
                      <p className="font-medium">{selectedStudent.email}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground mb-1">Phone</p>
                      <p className="font-medium">{selectedStudent.phone}</p>
                    </div>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground mb-2">Enrolled Courses</p>
                    <div className="flex gap-2 flex-wrap">
                      {selectedStudent.courses.length > 0 ? (
                        selectedStudent.courses.map((course, idx) => (
                          <Badge key={idx} variant="outline">
                            {course}
                          </Badge>
                        ))
                      ) : (
                        <p className="text-sm text-muted-foreground">No courses enrolled</p>
                      )}
                    </div>
                  </div>
                </TabsContent>
                <TabsContent value="documents" className="space-y-4 mt-4">
                  <div className="flex justify-between items-center">
                    <h3 className="font-semibold">Uploaded Documents</h3>
                    <Button size="sm" variant="outline">
                      <Upload className="w-4 h-4 mr-2" />
                      Upload
                    </Button>
                  </div>
                  <div className="space-y-2">
                    {selectedStudent.documents.map((doc, idx) => (
                      <div
                        key={idx}
                        className="flex items-center justify-between p-3 border border-border rounded-lg hover:bg-accent/50"
                      >
                        <div className="flex items-center gap-3">
                          <FileText className="w-5 h-5 text-primary" />
                          <div>
                            <p className="font-medium text-sm">{doc.name}</p>
                            <p className="text-xs text-muted-foreground">
                              {doc.type} • Uploaded {doc.uploadedDate}
                            </p>
                          </div>
                        </div>
                        <Button variant="ghost" size="sm">
                          <Download className="w-4 h-4" />
                        </Button>
                      </div>
                    ))}
                  </div>
                </TabsContent>
              </Tabs>
            )}
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
