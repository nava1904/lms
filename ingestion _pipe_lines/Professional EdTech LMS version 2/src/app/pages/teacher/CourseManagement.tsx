import { useState } from "react";
import { Plus, Edit, Trash2, Video, FileText, Upload } from "lucide-react";
import { Button } from "../../components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "../../components/ui/dialog";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../../components/ui/select";
import { TeacherTopBar } from "../../design-system/organisms/TeacherTopBar";
import { ClassCard } from "../../design-system/molecules/ClassCard";
import { Badge } from "../../design-system/atoms/Badge";

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
  subject: string;
  students: number;
  avgScore: number;
  completion: number;
  lessons: Lesson[];
}

const initialCourses: Course[] = [
  {
    id: "1",
    title: "Advanced Physics",
    subject: "Physics",
    students: 87,
    avgScore: 78,
    completion: 72,
    lessons: [
      {
        id: "l1",
        title: "Introduction to Newton's Laws",
        type: "video",
        duration: "12 min",
        status: "published",
      },
      { id: "l2", title: "First Law: Inertia", type: "video", duration: "18 min", status: "published" },
      { id: "l3", title: "Practice Problems", type: "document", status: "published" },
    ],
  },
  {
    id: "2",
    title: "Quantum Mechanics",
    subject: "Physics",
    students: 64,
    avgScore: 82,
    completion: 58,
    lessons: [
      {
        id: "l4",
        title: "Wave-Particle Duality",
        type: "video",
        duration: "25 min",
        status: "published",
      },
      {
        id: "l5",
        title: "Schrödinger Equation",
        type: "video",
        duration: "30 min",
        status: "draft",
      },
    ],
  },
  {
    id: "3",
    title: "Thermodynamics",
    subject: "Physics",
    students: 96,
    avgScore: 85,
    completion: 81,
    lessons: [
      { id: "l6", title: "Laws of Thermodynamics", type: "video", duration: "22 min", status: "published" },
      { id: "l7", title: "Heat Transfer", type: "video", duration: "20 min", status: "published" },
    ],
  },
];

export function CourseManagement() {
  const [courses, setCourses] = useState<Course[]>(initialCourses);
  const [selectedCourse, setSelectedCourse] = useState<Course | null>(null);
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
        course.id === selectedCourse.id
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

  // If a course is selected, show course detail view
  if (selectedCourse) {
    const course = courses.find((c) => c.id === selectedCourse.id);
    if (!course) {
      setSelectedCourse(null);
      return null;
    }

    return (
      <div className="min-h-screen bg-background">
        <TeacherTopBar teacherName="Dr. Johnson" notificationCount={5} />

        <div className="p-8">
          <div className="max-w-7xl mx-auto">
            {/* Back Button */}
            <button
              onClick={() => setSelectedCourse(null)}
              className="text-sm text-primary hover:underline mb-6 font-medium"
            >
              ← Back to All Courses
            </button>

            {/* Course Header */}
            <div className="bg-white rounded-xl p-6 shadow-[0_2px_8px_rgba(0,0,0,0.04)] border border-border mb-6">
              <div className="flex items-start justify-between">
                <div>
                  <h1 className="text-3xl font-bold text-foreground mb-2 font-['Outfit']">
                    {course.title}
                  </h1>
                  <div className="flex items-center gap-4 text-sm text-muted-foreground">
                    <span>{course.students} students enrolled</span>
                    <span>•</span>
                    <span>{course.lessons.length} lessons</span>
                    <span>•</span>
                    <span>Avg Score: {course.avgScore}%</span>
                  </div>
                </div>
                <Dialog open={isAddLessonOpen} onOpenChange={setIsAddLessonOpen}>
                  <DialogTrigger asChild>
                    <Button className="bg-primary hover:bg-primary/90">
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
                      <Button
                        onClick={handleAddLesson}
                        className="w-full bg-primary hover:bg-primary/90"
                      >
                        Add Lesson
                      </Button>
                    </div>
                  </DialogContent>
                </Dialog>
              </div>
            </div>

            {/* Lessons Table */}
            <div className="bg-white rounded-xl border border-border overflow-hidden shadow-[0_2px_8px_rgba(0,0,0,0.04)]">
              <div className="p-6 border-b border-border">
                <h2 className="text-xl font-semibold font-['Outfit']">Course Content</h2>
              </div>
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
                        <span className="text-sm text-muted-foreground">
                          {lesson.duration || "-"}
                        </span>
                      </td>
                      <td className="p-4">
                        {lesson.status === "published" ? (
                          <Badge variant="success">Published</Badge>
                        ) : (
                          <Badge variant="warning">Draft</Badge>
                        )}
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
        </div>
      </div>
    );
  }

  // Course list view
  return (
    <div className="min-h-screen bg-background">
      <TeacherTopBar teacherName="Dr. Johnson" notificationCount={5} />

      <div className="p-8">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">
              Course Management
            </h1>
            <p className="text-muted-foreground">Manage your courses and content</p>
          </div>

          {/* Courses Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {courses.map((course) => (
              <div key={course.id} onClick={() => setSelectedCourse(course)}>
                <ClassCard
                  id={course.id}
                  name={course.title}
                  subject={course.subject}
                  studentCount={course.students}
                  avgScore={course.avgScore}
                  completion={course.completion}
                />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
