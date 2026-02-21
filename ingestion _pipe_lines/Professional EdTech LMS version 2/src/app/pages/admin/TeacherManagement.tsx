import { useState } from "react";
import { Plus, Eye, Edit, Trash2, Mail, Phone, Key } from "lucide-react";
import { Button } from "../../components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "../../components/ui/dialog";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Badge } from "../../components/ui/badge";

interface Teacher {
  id: string;
  name: string;
  email: string;
  phone: string;
  subject: string;
  students: number;
  status: "active" | "inactive";
  teacherId: string;
}

const initialTeachers: Teacher[] = [
  {
    id: "1",
    name: "Dr. Sarah Johnson",
    email: "sarah.j@learnhub.com",
    phone: "+1 234-567-8901",
    subject: "Physics",
    students: 87,
    status: "active",
    teacherId: "TCH001",
  },
  {
    id: "2",
    name: "Prof. Michael Chen",
    email: "michael.c@learnhub.com",
    phone: "+1 234-567-8902",
    subject: "Mathematics",
    students: 124,
    status: "active",
    teacherId: "TCH002",
  },
  {
    id: "3",
    name: "Dr. Emily Roberts",
    email: "emily.r@learnhub.com",
    phone: "+1 234-567-8903",
    subject: "Chemistry",
    students: 96,
    status: "active",
    teacherId: "TCH003",
  },
];

export function TeacherManagement() {
  const [teachers, setTeachers] = useState<Teacher[]>(initialTeachers);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [selectedTeacher, setSelectedTeacher] = useState<Teacher | null>(null);
  const [newTeacher, setNewTeacher] = useState({
    name: "",
    email: "",
    phone: "",
    subject: "",
    password: "",
  });

  const generateTeacherId = () => {
    const num = teachers.length + 1;
    return `TCH${num.toString().padStart(3, "0")}`;
  };

  const handleAddTeacher = () => {
    const teacher: Teacher = {
      id: Date.now().toString(),
      name: newTeacher.name,
      email: newTeacher.email,
      phone: newTeacher.phone,
      subject: newTeacher.subject,
      students: 0,
      status: "active",
      teacherId: generateTeacherId(),
    };

    setTeachers([...teachers, teacher]);
    setNewTeacher({ name: "", email: "", phone: "", subject: "", password: "" });
    setIsAddDialogOpen(false);
  };

  const handleDelete = (id: string) => {
    setTeachers(teachers.filter((t) => t.id !== id));
  };

  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Teacher Management</h1>
            <p className="text-muted-foreground">Manage teacher accounts and credentials</p>
          </div>
          <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
            <DialogTrigger asChild>
              <Button className="bg-primary hover:bg-primary/90">
                <Plus className="w-4 h-4 mr-2" />
                Add Teacher
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Add New Teacher</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 mt-4">
                <div>
                  <Label htmlFor="name">Full Name</Label>
                  <Input
                    id="name"
                    value={newTeacher.name}
                    onChange={(e) => setNewTeacher({ ...newTeacher, name: e.target.value })}
                    placeholder="Dr. John Doe"
                  />
                </div>
                <div>
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    value={newTeacher.email}
                    onChange={(e) => setNewTeacher({ ...newTeacher, email: e.target.value })}
                    placeholder="john.doe@learnhub.com"
                  />
                </div>
                <div>
                  <Label htmlFor="phone">Phone</Label>
                  <Input
                    id="phone"
                    value={newTeacher.phone}
                    onChange={(e) => setNewTeacher({ ...newTeacher, phone: e.target.value })}
                    placeholder="+1 234-567-8900"
                  />
                </div>
                <div>
                  <Label htmlFor="subject">Subject</Label>
                  <Input
                    id="subject"
                    value={newTeacher.subject}
                    onChange={(e) => setNewTeacher({ ...newTeacher, subject: e.target.value })}
                    placeholder="e.g., Physics, Mathematics"
                  />
                </div>
                <div>
                  <Label htmlFor="password">Initial Password</Label>
                  <Input
                    id="password"
                    type="password"
                    value={newTeacher.password}
                    onChange={(e) => setNewTeacher({ ...newTeacher, password: e.target.value })}
                    placeholder="Create a secure password"
                  />
                </div>
                <div className="bg-accent/50 p-3 rounded-lg">
                  <p className="text-sm text-muted-foreground">
                    Teacher ID: <span className="font-mono font-medium text-foreground">{generateTeacherId()}</span>
                  </p>
                </div>
                <Button onClick={handleAddTeacher} className="w-full bg-primary hover:bg-primary/90">
                  Create Teacher Account
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>

        {/* Teachers Table */}
        <div className="bg-white rounded-xl shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border overflow-hidden">
          <table className="w-full">
            <thead className="bg-accent/50">
              <tr>
                <th className="text-left p-4 font-medium">Teacher ID</th>
                <th className="text-left p-4 font-medium">Name</th>
                <th className="text-left p-4 font-medium">Contact</th>
                <th className="text-left p-4 font-medium">Subject</th>
                <th className="text-left p-4 font-medium">Students</th>
                <th className="text-left p-4 font-medium">Status</th>
                <th className="text-right p-4 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {teachers.map((teacher) => (
                <tr key={teacher.id} className="hover:bg-accent/20">
                  <td className="p-4">
                    <span className="font-mono text-sm font-medium">{teacher.teacherId}</span>
                  </td>
                  <td className="p-4">
                    <p className="font-medium text-foreground">{teacher.name}</p>
                  </td>
                  <td className="p-4">
                    <div className="text-sm text-muted-foreground">
                      <p className="flex items-center gap-1">
                        <Mail className="w-3 h-3" />
                        {teacher.email}
                      </p>
                      <p className="flex items-center gap-1 mt-1">
                        <Phone className="w-3 h-3" />
                        {teacher.phone}
                      </p>
                    </div>
                  </td>
                  <td className="p-4">
                    <Badge variant="outline">{teacher.subject}</Badge>
                  </td>
                  <td className="p-4">
                    <span className="font-medium">{teacher.students}</span>
                  </td>
                  <td className="p-4">
                    <Badge
                      variant={teacher.status === "active" ? "default" : "secondary"}
                      className={
                        teacher.status === "active"
                          ? "bg-green-100 text-green-700 hover:bg-green-100"
                          : ""
                      }
                    >
                      {teacher.status}
                    </Badge>
                  </td>
                  <td className="p-4">
                    <div className="flex justify-end gap-2">
                      <Button variant="ghost" size="sm" onClick={() => setSelectedTeacher(teacher)}>
                        <Eye className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="sm">
                        <Edit className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="sm" onClick={() => handleDelete(teacher.id)}>
                        <Trash2 className="w-4 h-4 text-destructive" />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Teacher Details Dialog */}
        <Dialog open={!!selectedTeacher} onOpenChange={() => setSelectedTeacher(null)}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Teacher Details</DialogTitle>
            </DialogHeader>
            {selectedTeacher && (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Teacher ID</p>
                    <p className="font-mono font-medium">{selectedTeacher.teacherId}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Status</p>
                    <Badge variant="default" className="bg-green-100 text-green-700">
                      {selectedTeacher.status}
                    </Badge>
                  </div>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Name</p>
                  <p className="font-medium">{selectedTeacher.name}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Email</p>
                  <p className="font-medium">{selectedTeacher.email}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Phone</p>
                  <p className="font-medium">{selectedTeacher.phone}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Subject</p>
                  <Badge variant="outline">{selectedTeacher.subject}</Badge>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Total Students</p>
                  <p className="font-medium text-xl text-primary font-['Outfit']">
                    {selectedTeacher.students}
                  </p>
                </div>
                <Button className="w-full" variant="outline">
                  <Key className="w-4 h-4 mr-2" />
                  Reset Password
                </Button>
              </div>
            )}
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
