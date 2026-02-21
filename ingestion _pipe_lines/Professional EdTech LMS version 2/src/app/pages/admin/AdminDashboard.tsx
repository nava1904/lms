import { Users, GraduationCap, BookOpen, TrendingUp } from "lucide-react";
import { StatsCard } from "../../components/StatsCard";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

const enrollmentData = [
  { month: "Jan", students: 120 },
  { month: "Feb", students: 145 },
  { month: "Mar", students: 167 },
  { month: "Apr", students: 189 },
  { month: "May", students: 210 },
  { month: "Jun", students: 247 },
];

const recentActivities = [
  { action: "New Teacher Added", user: "Dr. Emily Roberts", time: "2 hours ago" },
  { action: "Student Registered", user: "Alex Thompson", time: "3 hours ago" },
  { action: "Test Scheduled", user: "Physics Mock Test 3", time: "5 hours ago" },
  { action: "Document Uploaded", user: "Student ID - John Doe", time: "1 day ago" },
];

export function AdminDashboard() {
  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Admin Dashboard</h1>
          <p className="text-muted-foreground">System overview and management</p>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatsCard
            icon={Users}
            label="Total Students"
            value="247"
            iconBgColor="bg-blue-50"
          />
          <StatsCard
            icon={GraduationCap}
            label="Active Teachers"
            value="18"
            iconBgColor="bg-green-50"
          />
          <StatsCard
            icon={BookOpen}
            label="Total Courses"
            value="42"
            iconBgColor="bg-purple-50"
          />
          <StatsCard
            icon={TrendingUp}
            label="System Health"
            value="98%"
            iconBgColor="bg-orange-50"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Enrollment Growth */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Student Enrollment Growth</h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={enrollmentData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" />
                <XAxis dataKey="month" tick={{ fill: "#64748B" }} />
                <YAxis tick={{ fill: "#64748B" }} />
                <Tooltip />
                <Bar dataKey="students" fill="#2563EB" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Recent Activities */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Recent System Activities</h2>
            <div className="space-y-4">
              {recentActivities.map((activity, index) => (
                <div key={index} className="flex items-start gap-3 p-3 rounded-lg bg-accent/50">
                  <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                    <div className="w-2 h-2 rounded-full bg-primary"></div>
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-foreground">{activity.action}</p>
                    <p className="text-sm text-muted-foreground">{activity.user}</p>
                  </div>
                  <span className="text-xs text-muted-foreground">{activity.time}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
          <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <button className="p-6 border-2 border-border rounded-lg hover:border-primary hover:bg-primary/5 transition-all text-center group">
              <GraduationCap className="w-8 h-8 mx-auto mb-3 text-primary" />
              <p className="font-medium">Add Teacher</p>
            </button>
            <button className="p-6 border-2 border-border rounded-lg hover:border-primary hover:bg-primary/5 transition-all text-center group">
              <Users className="w-8 h-8 mx-auto mb-3 text-primary" />
              <p className="font-medium">Add Student</p>
            </button>
            <button className="p-6 border-2 border-border rounded-lg hover:border-primary hover:bg-primary/5 transition-all text-center group">
              <BookOpen className="w-8 h-8 mx-auto mb-3 text-primary" />
              <p className="font-medium">Create Course</p>
            </button>
            <button className="p-6 border-2 border-border rounded-lg hover:border-primary hover:bg-primary/5 transition-all text-center group">
              <TrendingUp className="w-8 h-8 mx-auto mb-3 text-primary" />
              <p className="font-medium">View Reports</p>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
