import { useNavigate } from "react-router";
import { GraduationCap, Users, Shield, BookOpen, ArrowRight } from "lucide-react";
import { Button } from "../components/ui/button";

export function Home() {
  const navigate = useNavigate();

  const roles = [
    {
      title: "Student Portal",
      description: "Access your courses, track progress, and take tests",
      icon: GraduationCap,
      color: "from-blue-500 to-blue-600",
      path: "/student",
      features: ["Course Library", "Progress Tracking", "Test & Assessments", "Performance Analytics"],
    },
    {
      title: "Teacher Dashboard",
      description: "Manage courses, students, and track their performance",
      icon: Users,
      color: "from-green-500 to-emerald-600",
      path: "/teacher",
      features: ["Course Management", "Student Analytics", "Content Creation", "Grade Management"],
    },
    {
      title: "Admin Panel",
      description: "Complete system management and administration",
      icon: Shield,
      color: "from-purple-500 to-indigo-600",
      path: "/admin",
      features: ["User Management", "Attendance Tracking", "Test Scheduling", "System Reports"],
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#EFF6FF] to-white">
      <div className="max-w-7xl mx-auto px-8 py-16">
        {/* Header */}
        <div className="text-center mb-16">
          <div className="flex items-center justify-center gap-3 mb-6">
            <div className="w-16 h-16 rounded-2xl bg-primary flex items-center justify-center">
              <BookOpen className="w-10 h-10 text-primary-foreground" />
            </div>
            <span className="font-['Outfit'] text-5xl font-bold text-foreground">LearnHub</span>
          </div>
          <h1 className="text-5xl font-bold text-foreground mb-4 font-['Outfit']">
            Professional Learning Management System
          </h1>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Choose your role to access the platform with tailored features for students, teachers, and administrators
          </p>
        </div>

        {/* Role Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
          {roles.map((role) => (
            <div
              key={role.path}
              className="bg-white rounded-2xl p-8 shadow-[0_10px_40px_rgba(0,0,0,0.08)] border border-border hover:shadow-[0_20px_50px_rgba(0,0,0,0.12)] transition-all duration-300 hover:-translate-y-1"
            >
              <div className={`w-16 h-16 rounded-xl bg-gradient-to-br ${role.color} flex items-center justify-center mb-6`}>
                <role.icon className="w-9 h-9 text-white" />
              </div>
              <h2 className="text-2xl font-bold text-foreground mb-3 font-['Outfit']">{role.title}</h2>
              <p className="text-muted-foreground mb-6">{role.description}</p>
              
              <ul className="space-y-3 mb-8">
                {role.features.map((feature, idx) => (
                  <li key={idx} className="flex items-center gap-2 text-sm">
                    <div className="w-5 h-5 rounded-full bg-primary/10 flex items-center justify-center">
                      <ArrowRight className="w-3 h-3 text-primary" />
                    </div>
                    <span className="text-foreground">{feature}</span>
                  </li>
                ))}
              </ul>

              <Button
                onClick={() => navigate(role.path)}
                className="w-full bg-primary hover:bg-primary/90 text-primary-foreground"
              >
                Access {role.title.split(" ")[0]} Portal
              </Button>
            </div>
          ))}
        </div>

        {/* Demo Notice */}
        <div className="bg-blue-50 border border-blue-200 rounded-xl p-6 text-center">
          <p className="text-sm text-blue-900">
            <span className="font-semibold">Demo Mode:</span> This is a demonstration of a complete LMS platform. 
            You can switch between roles using the floating switcher in the bottom-right corner.
          </p>
        </div>
      </div>
    </div>
  );
}