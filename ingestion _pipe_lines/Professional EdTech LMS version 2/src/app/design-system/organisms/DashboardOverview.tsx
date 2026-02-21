import { BookOpen, Users, TrendingUp, Clock, AlertCircle } from "lucide-react";
import { StatCard } from "../molecules/StatCard";
import { LineChart, Line, ResponsiveContainer, Tooltip, CartesianGrid, XAxis, YAxis } from "recharts";

interface DashboardOverviewProps {
  stats: {
    activeCourses: number;
    totalStudents: number;
    avgPerformance: number;
    pendingReviews: number;
  };
  weeklyData: Array<{ day: string; students: number }>;
  recentActivity: Array<{ student: string; action: string; time: string }>;
  weakTopics?: Array<{ topic: string; avgScore: number }>;
}

export function DashboardOverview({
  stats,
  weeklyData,
  recentActivity,
  weakTopics = [],
}: DashboardOverviewProps) {
  return (
    <div className="space-y-8">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <StatCard
          icon={BookOpen}
          label="Active Courses"
          value={stats.activeCourses}
          change={{ value: 12, trend: "up" }}
          iconBgColor="bg-blue-50"
        />
        <StatCard
          icon={Users}
          label="Total Students"
          value={stats.totalStudents}
          change={{ value: 8, trend: "up" }}
          iconBgColor="bg-emerald-50"
        />
        <StatCard
          icon={TrendingUp}
          label="Avg. Performance"
          value={`${stats.avgPerformance}%`}
          change={{ value: 5, trend: "up" }}
          iconBgColor="bg-purple-50"
        />
        <StatCard
          icon={Clock}
          label="Pending Reviews"
          value={stats.pendingReviews}
          iconBgColor="bg-amber-50"
        />
      </div>

      {/* Two Column Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Weekly Engagement Chart */}
        <div className="bg-white rounded-xl p-6 shadow-[0_2px_8px_rgba(0,0,0,0.04)] border border-border">
          <h2 className="text-xl font-semibold mb-6 font-['Outfit']">Weekly Student Engagement</h2>
          <ResponsiveContainer width="100%" height={280}>
            <LineChart data={weeklyData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" />
              <XAxis dataKey="day" tick={{ fill: "#64748B", fontSize: 12 }} />
              <YAxis tick={{ fill: "#64748B", fontSize: 12 }} />
              <Tooltip
                contentStyle={{
                  backgroundColor: "#ffffff",
                  border: "1px solid #E2E8F0",
                  borderRadius: "8px",
                }}
              />
              <Line
                type="monotone"
                dataKey="students"
                stroke="#2563EB"
                strokeWidth={3}
                dot={{ fill: "#2563EB", r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-xl p-6 shadow-[0_2px_8px_rgba(0,0,0,0.04)] border border-border">
          <h2 className="text-xl font-semibold mb-6 font-['Outfit']">Recent Activity</h2>
          <div className="space-y-3">
            {recentActivity.map((activity, index) => (
              <div
                key={index}
                className="flex items-start gap-3 p-3 rounded-lg bg-accent/50 hover:bg-accent transition-colors"
              >
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Users className="w-4 h-4 text-primary" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-foreground">{activity.student}</p>
                  <p className="text-sm text-muted-foreground truncate">{activity.action}</p>
                </div>
                <span className="text-xs text-muted-foreground whitespace-nowrap">
                  {activity.time}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Weak Topics Alert */}
      {weakTopics.length > 0 && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-6">
          <div className="flex items-start gap-3">
            <div className="p-2 bg-amber-100 rounded-lg">
              <AlertCircle className="w-5 h-5 text-amber-600" />
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-amber-900 mb-2">Topics Needing Attention</h3>
              <p className="text-sm text-amber-700 mb-4">
                These topics have lower average scores and may need additional focus:
              </p>
              <div className="flex flex-wrap gap-3">
                {weakTopics.map((topic, index) => (
                  <div
                    key={index}
                    className="bg-white px-4 py-2 rounded-lg border border-amber-200 text-sm"
                  >
                    <span className="font-medium text-foreground">{topic.topic}</span>
                    <span className="text-amber-600 ml-2">({topic.avgScore}%)</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
