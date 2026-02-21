import { X, TrendingUp, Clock, FileText, AlertTriangle, Mail, UserPlus } from "lucide-react";
import { Avatar } from "../atoms/Avatar";
import { Badge } from "../atoms/Badge";
import { Button } from "../../components/ui/button";
import { ProgressBar } from "../atoms/ProgressBar";
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

interface StudentAnalyticsDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  student: {
    id: string;
    name: string;
    email: string;
    avatar?: string;
    avgScore: number;
    completion: number;
    totalTimeSpent: string;
    riskLevel?: "low" | "medium" | "high";
  };
  performanceData: Array<{ week: string; score: number }>;
  weakTopics: Array<{ topic: string; score: number }>;
  worksheetAttempts: Array<{ name: string; score: number; date: string }>;
}

export function StudentAnalyticsDrawer({
  isOpen,
  onClose,
  student,
  performanceData,
  weakTopics,
  worksheetAttempts,
}: StudentAnalyticsDrawerProps) {
  if (!isOpen) return null;

  const getRiskBadge = () => {
    if (!student.riskLevel || student.riskLevel === "low") return null;
    if (student.riskLevel === "high")
      return <Badge variant="danger">High Risk - Needs Immediate Support</Badge>;
    return <Badge variant="warning">Medium Risk - Monitor Progress</Badge>;
  };

  return (
    <>
      {/* Overlay */}
      <div
        className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40 transition-opacity"
        onClick={onClose}
      />

      {/* Drawer */}
      <div className="fixed right-0 top-0 h-full w-full max-w-2xl bg-white shadow-2xl z-50 overflow-y-auto animate-in slide-in-from-right duration-300">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-border px-6 py-4 z-10">
          <div className="flex items-start justify-between">
            <div className="flex items-start gap-4">
              <Avatar src={student.avatar} fallback={student.name} size="lg" />
              <div>
                <h2 className="text-2xl font-semibold mb-1 font-['Outfit']">{student.name}</h2>
                <p className="text-sm text-muted-foreground mb-2">{student.email}</p>
                {getRiskBadge()}
              </div>
            </div>
            <Button variant="ghost" size="sm" onClick={onClose}>
              <X className="w-5 h-5" />
            </Button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Quick Stats */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-accent/50 rounded-lg p-4 text-center">
              <TrendingUp className="w-6 h-6 text-primary mx-auto mb-2" />
              <p className="text-2xl font-semibold text-foreground">{student.avgScore}%</p>
              <p className="text-xs text-muted-foreground">Avg Score</p>
            </div>
            <div className="bg-accent/50 rounded-lg p-4 text-center">
              <FileText className="w-6 h-6 text-primary mx-auto mb-2" />
              <p className="text-2xl font-semibold text-foreground">{student.completion}%</p>
              <p className="text-xs text-muted-foreground">Completion</p>
            </div>
            <div className="bg-accent/50 rounded-lg p-4 text-center">
              <Clock className="w-6 h-6 text-primary mx-auto mb-2" />
              <p className="text-2xl font-semibold text-foreground">{student.totalTimeSpent}</p>
              <p className="text-xs text-muted-foreground">Time Spent</p>
            </div>
          </div>

          {/* Performance Trend */}
          <div className="bg-white border border-border rounded-xl p-5">
            <h3 className="text-lg font-semibold mb-4 font-['Outfit']">Performance Trend</h3>
            <ResponsiveContainer width="100%" height={200}>
              <LineChart data={performanceData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" />
                <XAxis dataKey="week" tick={{ fill: "#64748B", fontSize: 11 }} />
                <YAxis tick={{ fill: "#64748B", fontSize: 11 }} />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="score"
                  stroke="#2563EB"
                  strokeWidth={2}
                  dot={{ fill: "#2563EB" }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Weak Topics */}
          <div className="bg-white border border-border rounded-xl p-5">
            <div className="flex items-center gap-2 mb-4">
              <AlertTriangle className="w-5 h-5 text-amber-500" />
              <h3 className="text-lg font-semibold font-['Outfit']">Topics Needing Improvement</h3>
            </div>
            <div className="space-y-3">
              {weakTopics.map((topic, index) => (
                <div key={index}>
                  <div className="flex items-center justify-between mb-2 text-sm">
                    <span className="font-medium text-foreground">{topic.topic}</span>
                    <span className="text-muted-foreground">{topic.score}%</span>
                  </div>
                  <ProgressBar
                    value={topic.score}
                    variant={topic.score >= 60 ? "warning" : "danger"}
                    size="sm"
                  />
                </div>
              ))}
            </div>
          </div>

          {/* Recent Worksheet Attempts */}
          <div className="bg-white border border-border rounded-xl p-5">
            <h3 className="text-lg font-semibold mb-4 font-['Outfit']">Recent Worksheet Attempts</h3>
            <div className="space-y-3">
              {worksheetAttempts.map((attempt, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 bg-accent/30 rounded-lg"
                >
                  <div className="flex-1">
                    <p className="font-medium text-sm text-foreground">{attempt.name}</p>
                    <p className="text-xs text-muted-foreground">{attempt.date}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-lg font-semibold text-primary">{attempt.score}%</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Action Buttons */}
          <div className="grid grid-cols-2 gap-3">
            <Button variant="outline" className="w-full">
              <Mail className="w-4 h-4 mr-2" />
              Send Message
            </Button>
            <Button variant="default" className="w-full">
              <UserPlus className="w-4 h-4 mr-2" />
              Assign Worksheet
            </Button>
          </div>
        </div>
      </div>
    </>
  );
}
