import { useState } from "react";
import { Plus, Edit, Trash2, Video, FileText, Upload } from "lucide-react";
import { Button } from "../../components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "../../components/ui/dialog";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Textarea } from "../../components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../../components/ui/select";

interface Lesson {
  id: string;
  title: string;
  type: "video" | "document";
  duration?: string;
  status: "published" | "draft";
}

interface Course {
  id: string;
  title: string;
  students: number;
  lessons: Lesson[];
}

const initialCourses: Course[] = [
  {
    id: "1",
    title: "Advanced Physics: Newton's Laws",
    students: 87,
    lessons: [
      { id: "l1", title: "Introduction to Newton's Laws", type: "video", duration: "12 min", status: "published" },
      { id: "l2", title: "First Law: Inertia", type: "video", duration: "18 min", status: "published" },
      { id: "l3", title: "Practice Problems", type: "document", status: "published" },
    ],
  },
  {
    id: "2",
    title: "Quantum Mechanics Fundamentals",
    students: 64,
    lessons: [
      { id: "l4", title: "Wave-Particle Duality", type: "video", duration: "25 min", status: "published" },
      { id: "l5", title: "Schrödinger Equation", type: "video", duration: "30 min", status: "draft" },
    ],
  },
];

export function CourseManagement() {
  const [courses, setCourses] = useState<Course[]>(initialCourses);
  const [selectedCourse, setSelectedCourse] = useState<string | null>(null);
  const [isAddLessonOpen, setIsAddLessonOpen] = useState(false);
  const [newLesson, setNewLesson] = useState({
    title: "",
    type: "video" as "video" | "document",
    duration: "",
  });

  const handleAddLesson = () => {
    if (!selectedCourse || !newLesson.title) return;

    setCourses((prev) =>
      prev.map((course) =>
        course.id === selectedCourse
          ? {
              ...course,
              lessons: [
                ...course.lessons,
                {
                  id: `l${Date.now()}`,
                  title: newLesson.title,
                  type: newLesson.type,
                  duration: newLesson.duration,
                  status: "draft" as const,
                },
              ],
            }
          : course
      )
    );

    setNewLesson({ title: "", type: "video", duration: "" });
    setIsAddLessonOpen(false);
  };

  const handleDeleteLesson = (courseId: string, lessonId: string) => {
    setCourses((prev) =>
      prev.map((course) =>
        course.id === courseId
          ? { ...course, lessons: course.lessons.filter((l) => l.id !== lessonId) }
          : course
      )
    );
  };

  return (
    <div className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Course Management</h1>
          <p className="text-muted-foreground">Manage your courses and content</p>
        </div>

        {/* Courses List */}
        <div className="space-y-6">
          {courses.map((course) => (
            <div key={course.id} className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
              <div className="flex items-center justify-between mb-6">
                <div>
                  <h2 className="text-2xl font-semibold font-['Outfit']">{course.title}</h2>
                  <p className="text-sm text-muted-foreground">{course.students} students enrolled</p>
                </div>
                <Dialog open={isAddLessonOpen && selectedCourse === course.id} onOpenChange={setIsAddLessonOpen}>
                  <DialogTrigger asChild>
                    <Button
                      onClick={() => setSelectedCourse(course.id)}
                      className="bg-primary hover:bg-primary/90"
                    >
                      <Plus className="w-4 h-4 mr-2" />
                      Add Lesson
                    </Button>
                  </DialogTrigger>
                  <DialogContent>
                    <DialogHeader>
                      <DialogTitle>Add New Lesson</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 mt-4">
                      <div>
                        <Label htmlFor="lesson-title">Lesson Title</Label>
                        <Input
                          id="lesson-title"
                          value={newLesson.title}
                          onChange={(e) => setNewLesson({ ...newLesson, title: e.target.value })}
                          placeholder="Enter lesson title"
                        />
                      </div>
                      <div>
                        <Label htmlFor="lesson-type">Content Type</Label>
                        <Select
                          value={newLesson.type}
                          onValueChange={(value: "video" | "document") =>
                            setNewLesson({ ...newLesson, type: value })
                          }
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="video">Video</SelectItem>
                            <SelectItem value="document">Document</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      {newLesson.type === "video" && (
                        <div>
                          <Label htmlFor="duration">Duration (optional)</Label>
                          <Input
                            id="duration"
                            value={newLesson.duration}
                            onChange={(e) => setNewLesson({ ...newLesson, duration: e.target.value })}
                            placeholder="e.g., 15 min"
                          />
                        </div>
                      )}
                      <div>
                        <Label htmlFor="file-upload">Upload Content</Label>
                        <div className="border-2 border-dashed border-border rounded-lg p-8 text-center hover:border-primary transition-colors cursor-pointer">
                          <Upload className="w-8 h-8 mx-auto mb-2 text-muted-foreground" />
                          <p className="text-sm text-muted-foreground">
                            Click to upload or drag and drop
                          </p>
                        </div>
                      </div>
                      <Button onClick={handleAddLesson} className="w-full bg-primary hover:bg-primary/90">
                        Add Lesson
                      </Button>
                    </div>
                  </DialogContent>
                </Dialog>
              </div>

              {/* Lessons Table */}
              <div className="border border-border rounded-lg overflow-hidden">
                <table className="w-full">
                  <thead className="bg-accent/50">
                    <tr>
                      <th className="text-left p-4 font-medium text-sm">Lesson</th>
                      <th className="text-left p-4 font-medium text-sm">Type</th>
                      <th className="text-left p-4 font-medium text-sm">Duration</th>
                      <th className="text-left p-4 font-medium text-sm">Status</th>
                      <th className="text-right p-4 font-medium text-sm">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {course.lessons.map((lesson) => (
                      <tr key={lesson.id} className="hover:bg-accent/20">
                        <td className="p-4">
                          <div className="flex items-center gap-2">
                            {lesson.type === "video" ? (
                              <Video className="w-4 h-4 text-primary" />
                            ) : (
                              <FileText className="w-4 h-4 text-primary" />
                            )}
                            <span className="font-medium">{lesson.title}</span>
                          </div>
                        </td>
                        <td className="p-4">
                          <span className="text-sm capitalize">{lesson.type}</span>
                        </td>
                        <td className="p-4">
                          <span className="text-sm text-muted-foreground">{lesson.duration || "-"}</span>
                        </td>
                        <td className="p-4">
                          <span
                            className={`inline-flex px-2 py-1 rounded-full text-xs font-medium ${
                              lesson.status === "published"
                                ? "bg-green-100 text-green-700"
                                : "bg-yellow-100 text-yellow-700"
                            }`}
                          >
                            {lesson.status}
                          </span>
                        </td>
                        <td className="p-4">
                          <div className="flex justify-end gap-2">
                            <Button variant="ghost" size="sm">
                              <Edit className="w-4 h-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleDeleteLesson(course.id, lesson.id)}
                            >
                              <Trash2 className="w-4 h-4 text-destructive" />
                            </Button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
