import { useState } from "react";
import { Plus, Calendar, Clock, Users, Edit, Trash2 } from "lucide-react";
import { Button } from "../../components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "../../components/ui/dialog";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../../components/ui/select";
import { Badge } from "../../components/ui/badge";

interface Test {
  id: string;
  title: string;
  subject: string;
  date: string;
  time: string;
  duration: string;
  totalMarks: number;
  students: number;
  status: "upcoming" | "ongoing" | "completed";
}

const initialTests: Test[] = [
  {
    id: "1",
    title: "Physics Midterm Exam",
    subject: "Physics",
    date: "2026-02-20",
    time: "10:00 AM",
    duration: "2 hours",
    totalMarks: 100,
    students: 87,
    status: "upcoming",
  },
  {
    id: "2",
    title: "Math Quiz - Calculus",
    subject: "Mathematics",
    date: "2026-02-18",
    time: "2:00 PM",
    duration: "1 hour",
    totalMarks: 50,
    students: 124,
    status: "upcoming",
  },
  {
    id: "3",
    title: "Chemistry Lab Test",
    subject: "Chemistry",
    date: "2026-02-15",
    time: "11:00 AM",
    duration: "1.5 hours",
    totalMarks: 75,
    students: 96,
    status: "ongoing",
  },
];

export function TestScheduling() {
  const [tests, setTests] = useState<Test[]>(initialTests);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [newTest, setNewTest] = useState({
    title: "",
    subject: "",
    date: "",
    time: "",
    duration: "",
    totalMarks: "",
  });

  const handleAddTest = () => {
    const test: Test = {
      id: Date.now().toString(),
      title: newTest.title,
      subject: newTest.subject,
      date: newTest.date,
      time: newTest.time,
      duration: newTest.duration,
      totalMarks: parseInt(newTest.totalMarks),
      students: 0,
      status: "upcoming",
    };

    setTests([...tests, test]);
    setNewTest({ title: "", subject: "", date: "", time: "", duration: "", totalMarks: "" });
    setIsAddDialogOpen(false);
  };

  const handleDelete = (id: string) => {
    setTests(tests.filter((t) => t.id !== id));
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "upcoming":
        return <Badge className="bg-blue-100 text-blue-700 hover:bg-blue-100">Upcoming</Badge>;
      case "ongoing":
        return <Badge className="bg-green-100 text-green-700 hover:bg-green-100">Ongoing</Badge>;
      case "completed":
        return <Badge className="bg-gray-100 text-gray-700 hover:bg-gray-100">Completed</Badge>;
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Test Scheduling</h1>
            <p className="text-muted-foreground">Schedule and manage tests and examinations</p>
          </div>
          <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
            <DialogTrigger asChild>
              <Button className="bg-primary hover:bg-primary/90">
                <Plus className="w-4 h-4 mr-2" />
                Schedule Test
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Schedule New Test</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 mt-4">
                <div>
                  <Label htmlFor="test-title">Test Title</Label>
                  <Input
                    id="test-title"
                    value={newTest.title}
                    onChange={(e) => setNewTest({ ...newTest, title: e.target.value })}
                    placeholder="e.g., Physics Midterm Exam"
                  />
                </div>
                <div>
                  <Label htmlFor="subject">Subject</Label>
                  <Select
                    value={newTest.subject}
                    onValueChange={(value) => setNewTest({ ...newTest, subject: value })}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select subject" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Physics">Physics</SelectItem>
                      <SelectItem value="Mathematics">Mathematics</SelectItem>
                      <SelectItem value="Chemistry">Chemistry</SelectItem>
                      <SelectItem value="Biology">Biology</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="date">Date</Label>
                    <Input
                      id="date"
                      type="date"
                      value={newTest.date}
                      onChange={(e) => setNewTest({ ...newTest, date: e.target.value })}
                    />
                  </div>
                  <div>
                    <Label htmlFor="time">Time</Label>
                    <Input
                      id="time"
                      type="time"
                      value={newTest.time}
                      onChange={(e) => setNewTest({ ...newTest, time: e.target.value })}
                    />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="duration">Duration</Label>
                    <Input
                      id="duration"
                      value={newTest.duration}
                      onChange={(e) => setNewTest({ ...newTest, duration: e.target.value })}
                      placeholder="e.g., 2 hours"
                    />
                  </div>
                  <div>
                    <Label htmlFor="marks">Total Marks</Label>
                    <Input
                      id="marks"
                      type="number"
                      value={newTest.totalMarks}
                      onChange={(e) => setNewTest({ ...newTest, totalMarks: e.target.value })}
                      placeholder="100"
                    />
                  </div>
                </div>
                <Button onClick={handleAddTest} className="w-full bg-primary hover:bg-primary/90">
                  Schedule Test
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>

        {/* Tests Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {tests.map((test) => (
            <div
              key={test.id}
              className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border hover:shadow-lg transition-shadow"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <h3 className="font-semibold text-lg mb-1 font-['Outfit']">{test.title}</h3>
                  <p className="text-sm text-muted-foreground">{test.subject}</p>
                </div>
                {getStatusBadge(test.status)}
              </div>

              <div className="space-y-3">
                <div className="flex items-center gap-2 text-sm">
                  <Calendar className="w-4 h-4 text-muted-foreground" />
                  <span>{new Date(test.date).toLocaleDateString("en-US", { 
                    month: "short", 
                    day: "numeric", 
                    year: "numeric" 
                  })}</span>
                </div>
                <div className="flex items-center gap-2 text-sm">
                  <Clock className="w-4 h-4 text-muted-foreground" />
                  <span>{test.time} • {test.duration}</span>
                </div>
                <div className="flex items-center gap-2 text-sm">
                  <Users className="w-4 h-4 text-muted-foreground" />
                  <span>{test.students} students</span>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-border">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Total Marks</span>
                  <span className="text-lg font-semibold text-primary font-['Outfit']">
                    {test.totalMarks}
                  </span>
                </div>
              </div>

              <div className="flex gap-2 mt-4">
                <Button variant="outline" size="sm" className="flex-1">
                  <Edit className="w-4 h-4 mr-2" />
                  Edit
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  className="flex-1"
                  onClick={() => handleDelete(test.id)}
                >
                  <Trash2 className="w-4 h-4 mr-2 text-destructive" />
                  Delete
                </Button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
