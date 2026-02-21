import { useState } from "react";
import { ChevronDown, ChevronRight, Play, Check, Lock } from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "../components/ui/collapsible";

interface Lesson {
  id: string;
  title: string;
  duration: string;
  status: "completed" | "current" | "locked";
}

interface Chapter {
  id: string;
  title: string;
  lessonCount: number;
  lessons: Lesson[];
}

const curriculum: Chapter[] = [
  {
    id: "ch1",
    title: "Newton's Laws",
    lessonCount: 4,
    lessons: [
      { id: "l1", title: "Introduction to Newton's Laws", duration: "12 min", status: "completed" },
      { id: "l2", title: "First Law: Inertia", duration: "18 min", status: "completed" },
      { id: "l3", title: "Second Law: F=ma", duration: "22 min", status: "current" },
      { id: "l4", title: "Third Law: Action-Reaction", duration: "15 min", status: "locked" },
    ],
  },
  {
    id: "ch2",
    title: "Forces and Motion",
    lessonCount: 5,
    lessons: [
      { id: "l5", title: "Types of Forces", duration: "14 min", status: "locked" },
      { id: "l6", title: "Friction", duration: "16 min", status: "locked" },
      { id: "l7", title: "Normal Force", duration: "13 min", status: "locked" },
      { id: "l8", title: "Tension", duration: "17 min", status: "locked" },
      { id: "l9", title: "Problem Solving", duration: "25 min", status: "locked" },
    ],
  },
  {
    id: "ch3",
    title: "Energy and Work",
    lessonCount: 3,
    lessons: [
      { id: "l10", title: "Work-Energy Theorem", duration: "20 min", status: "locked" },
      { id: "l11", title: "Kinetic Energy", duration: "15 min", status: "locked" },
      { id: "l12", title: "Potential Energy", duration: "18 min", status: "locked" },
    ],
  },
];

export function CoursePlayer() {
  const [openChapters, setOpenChapters] = useState<string[]>(["ch1"]);

  const toggleChapter = (chapterId: string) => {
    setOpenChapters((prev) =>
      prev.includes(chapterId)
        ? prev.filter((id) => id !== chapterId)
        : [...prev, chapterId]
    );
  };

  const getStatusIcon = (status: Lesson["status"]) => {
    switch (status) {
      case "completed":
        return <Check className="w-4 h-4 text-green-600" />;
      case "current":
        return <Play className="w-4 h-4 text-primary" />;
      case "locked":
        return <Lock className="w-4 h-4 text-muted-foreground" />;
    }
  };

  return (
    <div className="flex h-screen bg-background">
      {/* Left Panel - Video Player & Tabs */}
      <div className="flex-1 flex flex-col">
        {/* Video Player */}
        <div className="bg-black aspect-video flex items-center justify-center">
          <div className="text-center">
            <Play className="w-20 h-20 text-white mx-auto mb-4 opacity-80" />
            <p className="text-white text-lg">Advanced Physics: Second Law (F=ma)</p>
            <p className="text-gray-400 text-sm mt-2">Duration: 22 minutes</p>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex-1 overflow-y-auto">
          <Tabs defaultValue="overview" className="w-full">
            <TabsList className="w-full justify-start rounded-none border-b bg-white h-14 px-8">
              <TabsTrigger value="overview" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none">
                Overview
              </TabsTrigger>
              <TabsTrigger value="qa" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none">
                Q&A
              </TabsTrigger>
              <TabsTrigger value="notes" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none">
                Notes
              </TabsTrigger>
              <TabsTrigger value="resources" className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none">
                Resources
              </TabsTrigger>
            </TabsList>

            <TabsContent value="overview" className="p-8">
              <h2 className="text-2xl font-semibold mb-4 font-['Outfit']">About This Lesson</h2>
              <p className="text-muted-foreground leading-relaxed mb-6">
                In this lesson, we'll explore Newton's Second Law of Motion, which states that the acceleration of an object
                depends on the net force acting upon it and its mass. This fundamental principle is expressed mathematically
                as F = ma, where F is force, m is mass, and a is acceleration.
              </p>
              <h3 className="text-xl font-semibold mb-3 font-['Outfit']">What You'll Learn</h3>
              <ul className="space-y-2 text-muted-foreground">
                <li className="flex items-start gap-2">
                  <Check className="w-5 h-5 text-green-600 mt-0.5" />
                  <span>Understand the relationship between force, mass, and acceleration</span>
                </li>
                <li className="flex items-start gap-2">
                  <Check className="w-5 h-5 text-green-600 mt-0.5" />
                  <span>Apply F=ma to solve real-world physics problems</span>
                </li>
                <li className="flex items-start gap-2">
                  <Check className="w-5 h-5 text-green-600 mt-0.5" />
                  <span>Analyze force diagrams and vector components</span>
                </li>
                <li className="flex items-start gap-2">
                  <Check className="w-5 h-5 text-green-600 mt-0.5" />
                  <span>Calculate net force from multiple force vectors</span>
                </li>
              </ul>
            </TabsContent>

            <TabsContent value="qa" className="p-8">
              <h2 className="text-2xl font-semibold mb-4 font-['Outfit']">Questions & Answers</h2>
              <p className="text-muted-foreground">No questions yet. Be the first to ask!</p>
            </TabsContent>

            <TabsContent value="notes" className="p-8">
              <h2 className="text-2xl font-semibold mb-4 font-['Outfit']">My Notes</h2>
              <p className="text-muted-foreground">Your notes will appear here as you watch the video.</p>
            </TabsContent>

            <TabsContent value="resources" className="p-8">
              <h2 className="text-2xl font-semibold mb-4 font-['Outfit']">Downloadable Resources</h2>
              <div className="space-y-3">
                <div className="p-4 border border-border rounded-lg hover:bg-accent cursor-pointer">
                  <p className="font-medium">Newton's Laws Cheat Sheet.pdf</p>
                  <p className="text-sm text-muted-foreground">2.4 MB</p>
                </div>
                <div className="p-4 border border-border rounded-lg hover:bg-accent cursor-pointer">
                  <p className="font-medium">Practice Problems.pdf</p>
                  <p className="text-sm text-muted-foreground">1.8 MB</p>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </div>

      {/* Right Panel - Curriculum */}
      <div className="w-96 border-l border-border bg-white overflow-y-auto">
        <div className="p-6 border-b border-border">
          <h2 className="text-xl font-semibold font-['Outfit']">Course Content</h2>
          <p className="text-sm text-muted-foreground mt-1">12 lessons • 3h 24min</p>
        </div>

        <div className="divide-y divide-border">
          {curriculum.map((chapter) => (
            <Collapsible
              key={chapter.id}
              open={openChapters.includes(chapter.id)}
              onOpenChange={() => toggleChapter(chapter.id)}
            >
              <CollapsibleTrigger className="w-full p-4 hover:bg-accent transition-colors flex items-center justify-between group">
                <div className="flex items-center gap-3">
                  {openChapters.includes(chapter.id) ? (
                    <ChevronDown className="w-5 h-5 text-muted-foreground" />
                  ) : (
                    <ChevronRight className="w-5 h-5 text-muted-foreground" />
                  )}
                  <div className="text-left">
                    <p className="font-medium text-foreground">{chapter.title}</p>
                    <p className="text-xs text-muted-foreground">{chapter.lessonCount} lessons</p>
                  </div>
                </div>
              </CollapsibleTrigger>
              <CollapsibleContent>
                <div className="bg-accent/30">
                  {chapter.lessons.map((lesson) => (
                    <div
                      key={lesson.id}
                      className={`p-4 pl-12 hover:bg-accent cursor-pointer flex items-center justify-between ${
                        lesson.status === "current" ? "bg-primary/5 border-l-2 border-primary" : ""
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        {getStatusIcon(lesson.status)}
                        <div>
                          <p className="text-sm font-medium text-foreground">{lesson.title}</p>
                        </div>
                      </div>
                      <span className="text-xs text-muted-foreground">{lesson.duration}</span>
                    </div>
                  ))}
                </div>
              </CollapsibleContent>
            </Collapsible>
          ))}
        </div>
      </div>
    </div>
  );
}
