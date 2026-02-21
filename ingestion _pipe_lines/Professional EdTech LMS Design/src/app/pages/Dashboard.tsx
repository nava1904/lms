import { Search, Clock, Target, BookOpen } from "lucide-react";
import { StatsCard } from "../components/StatsCard";
import { CourseCard } from "../components/CourseCard";
import Masonry from "react-responsive-masonry";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";

const courses = [
  {
    id: "physics-101",
    title: "Advanced Physics: Newton's Laws and Motion",
    instructor: "Dr. Sarah Johnson",
    image: "https://images.unsplash.com/photo-1758685734463-98672a67dd1c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaHlzaWNzJTIwZWR1Y2F0aW9uJTIwY2xhc3Nyb29tfGVufDF8fHx8MTc3MTA4NzczOXww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Physics",
    rating: 4.8,
    price: "$49",
    enrolled: true,
  },
  {
    id: "math-201",
    title: "Calculus Fundamentals: Derivatives and Integrals",
    instructor: "Prof. Michael Chen",
    image: "https://images.unsplash.com/photo-1758685734312-5134968399a8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYXRoZW1hdGljcyUyMGNoYWxrYm9hcmQlMjBmb3JtdWxhc3xlbnwxfHx8fDE3NzEwODc3Mzl8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Mathematics",
    rating: 4.9,
    price: "$59",
  },
  {
    id: "chem-101",
    title: "Organic Chemistry: Reactions and Mechanisms",
    instructor: "Dr. Emily Roberts",
    image: "https://images.unsplash.com/photo-1608037222022-62649819f8aa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaGVtaXN0cnklMjBsYWJvcmF0b3J5JTIwZXhwZXJpbWVudHxlbnwxfHx8fDE3NzEwODc3NDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Chemistry",
    rating: 4.7,
    price: "$54",
  },
  {
    id: "cs-301",
    title: "Data Structures and Algorithms in Python",
    instructor: "James Anderson",
    image: "https://images.unsplash.com/photo-1624953587687-daf255b6b80a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21wdXRlciUyMHNjaWVuY2UlMjBwcm9ncmFtbWluZ3xlbnwxfHx8fDE3NzEwNjczMzd8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Computer Science",
    rating: 4.9,
    price: "$79",
    enrolled: true,
  },
  {
    id: "bio-201",
    title: "Cell Biology: Structure and Function",
    instructor: "Dr. Rachel Green",
    image: "https://images.unsplash.com/photo-1743792930023-774d74a015cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiaW9sb2d5JTIwbWljcm9zY29wZSUyMHNjaWVuY2V8ZW58MXx8fHwxNzcxMDI2OTg0fDA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Biology",
    rating: 4.6,
    price: "$44",
  },
  {
    id: "eng-101",
    title: "Engineering Design: CAD and 3D Modeling",
    instructor: "Prof. David Kim",
    image: "https://images.unsplash.com/photo-1581092335331-5e00ac65e934?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbmdpbmVlcmluZyUyMHRlY2hub2xvZ3klMjBkZXNpZ258ZW58MXx8fHwxNzcxMDg3NzQxfDA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Engineering",
    rating: 4.8,
    price: "$69",
  },
];

export function Dashboard() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <div className="bg-gradient-to-b from-[#EFF6FF] to-white px-8 py-12 mb-8">
        <div className="max-w-7xl mx-auto">
          <h1 className="text-5xl font-bold text-foreground mb-6 font-['Outfit']">
            Unlock Your Potential
          </h1>
          <p className="text-lg text-muted-foreground mb-6 max-w-2xl">
            Explore thousands of courses and master new skills with expert instructors
          </p>
          
          {/* Search Bar */}
          <div className="flex gap-2 max-w-2xl">
            <div className="relative flex-1">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <Input
                placeholder="Search for courses, skills, or topics..."
                className="pl-12 h-14 rounded-full bg-white border-2 border-border shadow-sm"
              />
            </div>
            <Button className="h-14 px-8 rounded-full bg-primary hover:bg-primary/90 text-primary-foreground">
              Go
            </Button>
          </div>
        </div>
      </div>

      <div className="px-8 pb-12">
        <div className="max-w-7xl mx-auto">
          {/* Stats Row */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
            <StatsCard
              icon={Clock}
              label="Hours Spent"
              value="127h"
              iconBgColor="bg-blue-50"
            />
            <StatsCard
              icon={Target}
              label="Test Score"
              value="92%"
              iconBgColor="bg-green-50"
            />
            <StatsCard
              icon={BookOpen}
              label="Active Courses"
              value="8"
              iconBgColor="bg-purple-50"
            />
          </div>

          {/* Course Grid */}
          <div className="mb-6">
            <h2 className="text-3xl font-semibold text-foreground mb-6 font-['Outfit']">
              Explore Courses
            </h2>
          </div>

          <Masonry columnsCount={3} gutter="24px">
            {courses.map((course) => (
              <CourseCard key={course.id} {...course} />
            ))}
          </Masonry>
        </div>
      </div>
    </div>
  );
}
