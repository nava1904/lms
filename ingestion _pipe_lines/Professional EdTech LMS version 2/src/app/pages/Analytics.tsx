import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { TrendingUp, TrendingDown, Award, Target } from "lucide-react";
import { Badge } from "../components/ui/badge";

const accuracyData = [
  { name: "Correct", value: 72, color: "#10B981" },
  { name: "Incorrect", value: 28, color: "#EF4444" },
];

const subjectData = [
  { subject: "Physics", score: 85 },
  { subject: "Math", score: 92 },
  { subject: "Chemistry", score: 78 },
  { subject: "Biology", score: 88 },
];

const weakTopics = [
  "Friction",
  "Optics",
  "Thermodynamics",
  "Organic Chemistry",
  "Calculus",
  "Electromagnetic Waves",
  "Quantum Mechanics",
  "Kinematics",
];

const recentTests = [
  { name: "Physics Mock Test 1", score: 85, date: "Feb 10, 2026", trend: "up" },
  { name: "Math Practice Test", score: 92, date: "Feb 8, 2026", trend: "up" },
  { name: "Chemistry Quiz", score: 78, date: "Feb 5, 2026", trend: "down" },
  { name: "Biology Assessment", score: 88, date: "Feb 3, 2026", trend: "up" },
];

export function Analytics() {
  return (
    <div className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Performance Analytics</h1>
          <p className="text-muted-foreground">Track your progress and identify areas for improvement</p>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <Award className="w-8 h-8 text-yellow-500" />
              <TrendingUp className="w-5 h-5 text-green-600" />
            </div>
            <p className="text-3xl font-bold text-foreground font-['Outfit']">86%</p>
            <p className="text-sm text-muted-foreground">Overall Score</p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <Target className="w-8 h-8 text-blue-500" />
              <TrendingUp className="w-5 h-5 text-green-600" />
            </div>
            <p className="text-3xl font-bold text-foreground font-['Outfit']">72%</p>
            <p className="text-sm text-muted-foreground">Accuracy Rate</p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <div className="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center">
                <span className="text-lg font-bold text-purple-600">24</span>
              </div>
            </div>
            <p className="text-3xl font-bold text-foreground font-['Outfit']">24</p>
            <p className="text-sm text-muted-foreground">Tests Completed</p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                <span className="text-lg font-bold text-green-600">12</span>
              </div>
            </div>
            <p className="text-3xl font-bold text-foreground font-['Outfit']">127h</p>
            <p className="text-sm text-muted-foreground">Study Hours</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Accuracy Donut Chart */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Overall Accuracy</h2>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={accuracyData}
                  cx="50%"
                  cy="50%"
                  innerRadius={80}
                  outerRadius={120}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {accuracyData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex justify-center gap-6 mt-4">
              {accuracyData.map((entry) => (
                <div key={entry.name} className="flex items-center gap-2">
                  <div className="w-4 h-4 rounded" style={{ backgroundColor: entry.color }}></div>
                  <span className="text-sm text-muted-foreground">
                    {entry.name}: {entry.value}%
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Subject Performance Bar Chart */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-6 font-['Outfit']">Subject Performance</h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={subjectData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" />
                <XAxis dataKey="subject" tick={{ fill: "#64748B" }} />
                <YAxis tick={{ fill: "#64748B" }} />
                <Tooltip />
                <Bar dataKey="score" fill="#2563EB" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Weak Areas */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-4 font-['Outfit']">Areas to Improve</h2>
            <p className="text-sm text-muted-foreground mb-4">
              Focus on these topics to boost your performance
            </p>
            <div className="flex flex-wrap gap-2">
              {weakTopics.map((topic) => (
                <Badge
                  key={topic}
                  variant="destructive"
                  className="bg-red-50 text-red-700 hover:bg-red-100 border border-red-200 px-3 py-1.5 text-sm"
                >
                  {topic}
                </Badge>
              ))}
            </div>
          </div>

          {/* Recent Tests */}
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <h2 className="text-2xl font-semibold mb-4 font-['Outfit']">Recent Tests</h2>
            <div className="space-y-3">
              {recentTests.map((test, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 rounded-lg bg-accent/50 border border-border"
                >
                  <div className="flex-1">
                    <p className="font-medium text-foreground">{test.name}</p>
                    <p className="text-xs text-muted-foreground">{test.date}</p>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-lg font-semibold text-primary font-['Outfit']">
                      {test.score}%
                    </span>
                    {test.trend === "up" ? (
                      <TrendingUp className="w-5 h-5 text-green-600" />
                    ) : (
                      <TrendingDown className="w-5 h-5 text-red-600" />
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
