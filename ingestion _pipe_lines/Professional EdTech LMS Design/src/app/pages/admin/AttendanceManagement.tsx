import { useState } from "react";
import { Calendar, Download, Users, CheckCircle, XCircle } from "lucide-react";
import { Button } from "../../components/ui/button";
import { Badge } from "../../components/ui/badge";
import { Input } from "../../components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../../components/ui/select";

interface AttendanceRecord {
  id: string;
  name: string;
  studentId: string;
  status: "present" | "absent" | "late";
  date: string;
}

const attendanceData: AttendanceRecord[] = [
  { id: "1", name: "John Doe", studentId: "STU001", status: "present", date: "2026-02-14" },
  { id: "2", name: "Emma Wilson", studentId: "STU002", status: "present", date: "2026-02-14" },
  { id: "3", name: "Michael Chen", studentId: "STU003", status: "absent", date: "2026-02-14" },
  { id: "4", name: "Sarah Parker", studentId: "STU004", status: "late", date: "2026-02-14" },
  { id: "5", name: "Alex Thompson", studentId: "STU005", status: "present", date: "2026-02-14" },
];

export function AttendanceManagement() {
  const [selectedCourse, setSelectedCourse] = useState("physics");
  const [selectedDate, setSelectedDate] = useState("2026-02-14");
  const [attendance, setAttendance] = useState<AttendanceRecord[]>(attendanceData);

  const toggleAttendance = (id: string) => {
    setAttendance((prev) =>
      prev.map((record) => {
        if (record.id === id) {
          const statuses: ("present" | "absent" | "late")[] = ["present", "absent", "late"];
          const currentIndex = statuses.indexOf(record.status);
          const nextStatus = statuses[(currentIndex + 1) % statuses.length];
          return { ...record, status: nextStatus };
        }
        return record;
      })
    );
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "present":
        return <Badge className="bg-green-100 text-green-700 hover:bg-green-100">Present</Badge>;
      case "absent":
        return <Badge className="bg-red-100 text-red-700 hover:bg-red-100">Absent</Badge>;
      case "late":
        return <Badge className="bg-yellow-100 text-yellow-700 hover:bg-yellow-100">Late</Badge>;
      default:
        return null;
    }
  };

  const stats = {
    present: attendance.filter((r) => r.status === "present").length,
    absent: attendance.filter((r) => r.status === "absent").length,
    late: attendance.filter((r) => r.status === "late").length,
  };

  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Attendance Management</h1>
          <p className="text-muted-foreground">Track and manage student attendance</p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <Users className="w-8 h-8 text-blue-500" />
            </div>
            <p className="text-3xl font-bold text-foreground font-['Outfit']">{attendance.length}</p>
            <p className="text-sm text-muted-foreground">Total Students</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <CheckCircle className="w-8 h-8 text-green-500" />
            </div>
            <p className="text-3xl font-bold text-green-600 font-['Outfit']">{stats.present}</p>
            <p className="text-sm text-muted-foreground">Present</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <XCircle className="w-8 h-8 text-red-500" />
            </div>
            <p className="text-3xl font-bold text-red-600 font-['Outfit']">{stats.absent}</p>
            <p className="text-sm text-muted-foreground">Absent</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
            <div className="flex items-center justify-between mb-2">
              <Calendar className="w-8 h-8 text-yellow-500" />
            </div>
            <p className="text-3xl font-bold text-yellow-600 font-['Outfit']">{stats.late}</p>
            <p className="text-sm text-muted-foreground">Late</p>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border mb-6">
          <div className="flex items-center gap-4">
            <div className="flex-1">
              <label className="text-sm font-medium mb-2 block">Course</label>
              <Select value={selectedCourse} onValueChange={setSelectedCourse}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="physics">Advanced Physics</SelectItem>
                  <SelectItem value="math">Mathematics</SelectItem>
                  <SelectItem value="chemistry">Chemistry</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="flex-1">
              <label className="text-sm font-medium mb-2 block">Date</label>
              <Input
                type="date"
                value={selectedDate}
                onChange={(e) => setSelectedDate(e.target.value)}
                className="w-full"
              />
            </div>
            <div className="flex items-end">
              <Button variant="outline">
                <Download className="w-4 h-4 mr-2" />
                Export
              </Button>
            </div>
          </div>
        </div>

        {/* Attendance Table */}
        <div className="bg-white rounded-xl shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border overflow-hidden">
          <div className="p-6 border-b border-border">
            <h2 className="text-xl font-semibold font-['Outfit']">Attendance Records - {selectedDate}</h2>
          </div>
          <table className="w-full">
            <thead className="bg-accent/50">
              <tr>
                <th className="text-left p-4 font-medium">Student ID</th>
                <th className="text-left p-4 font-medium">Name</th>
                <th className="text-left p-4 font-medium">Status</th>
                <th className="text-right p-4 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {attendance.map((record) => (
                <tr key={record.id} className="hover:bg-accent/20">
                  <td className="p-4">
                    <span className="font-mono text-sm font-medium">{record.studentId}</span>
                  </td>
                  <td className="p-4">
                    <p className="font-medium text-foreground">{record.name}</p>
                  </td>
                  <td className="p-4">{getStatusBadge(record.status)}</td>
                  <td className="p-4">
                    <div className="flex justify-end gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => toggleAttendance(record.id)}
                      >
                        Toggle Status
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
  );
}