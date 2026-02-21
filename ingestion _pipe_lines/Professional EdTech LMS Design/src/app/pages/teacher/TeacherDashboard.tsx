import { BookOpen, Users, TrendingUp, Clock } from "lucide-react";
import { StatsCard } from "../../components/StatsCard";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from "recharts";

const weeklyEngagement = [
  { day: "Mon", students: 45 },
  { day: "Tue", students: 52 },
  { day: "Wed", students: 48 },
  { day: "Thu", students: 60 },
  { day: "Fri", students: 55 },
  { day: "Sat", students: 38 },
  { day: "Sun", students: 30 },
];

const recentActivity = [
  { student: "John Doe", action: "Completed Physics Chapter 3", time: "2 hours ago" },
  { student: "Emma Wilson", action: "Submitted Assignment 5", time: "3 hours ago" },
  { student: "Michael Chen", action: "Asked a question in Q&A", time: "5 hours ago" },
  { student: "Sarah Parker", action: "Watched Lecture 12", time: "1 day ago" },
];

export function TeacherDashboard() {
  return (
    <div className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Welcome Back, Dr. Johnson</h1>
          <p className="text-muted-foreground">Here's what's happening with your courses today</p>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatsCard
            icon={BookOpen}
            label="Active Courses"
            value="5"
            iconBgColor="bg-blue-50"
          />
          <StatsCard
            icon={Users}
            label="Total Students"
            value="247"
            iconBgColor="bg-green-50"
          />
          <StatsCard
            icon={TrendingUp}
            label="Avg. Performance"
            value="85%"
            iconBgColor="bg-purple-50"
          />
          <StatsCard
            icon={Clock}
            label="Pending Reviews"
            value="12"
            iconBgColor="bg-orange-50"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Weekly Student Engagement */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Weekly Student Engagement</h2>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={weeklyEngagement}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" />
                <XAxis dataKey="day" tick={{ fill: "#64748B" }} />
                <YAxis tick={{ fill: "#64748B" }} />
                <Tooltip />
                <Line type="monotone" dataKey="students" stroke="#2563EB" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Recent Activity */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Recent Activity</h2>
            <div className="space-y-4">
              {recentActivity.map((activity, index) => (
                <div key={index} className="flex items-start gap-3 p-3 rounded-lg bg-accent/50">
                  <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                    <Users className="w-4 h-4 text-primary" />
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-foreground">{activity.student}</p>
                    <p className="text-sm text-muted-foreground">{activity.action}</p>
                  </div>
                  <span className="text-xs text-muted-foreground">{activity.time}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Course Overview */}
        <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
          <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">My Courses</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[
              { name: "Advanced Physics", students: 87, completion: 72 },
              { name: "Quantum Mechanics", students: 64, completion: 58 },
              { name: "Thermodynamics", students: 96, completion: 81 },
            ].map((course, index) => (
              <div key={index} className="p-5 rounded-lg border border-border hover:shadow-md transition-shadow cursor-pointer">
                <h3 className="font-semibold text-lg mb-3">{course.name}</h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Students</span>
                    <span className="font-medium">{course.students}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Avg. Completion</span>
                    <span className="font-medium">{course.completion}%</span>
                  </div>
                  <div className="w-full bg-accent h-2 rounded-full mt-2">
                    <div
                      className="bg-primary h-2 rounded-full"
                      style={{ width: `${course.completion}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
