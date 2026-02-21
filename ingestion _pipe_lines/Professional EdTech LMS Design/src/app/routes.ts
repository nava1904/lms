import { createBrowserRouter } from "react-router";
import { DashboardLayout } from "./components/DashboardLayout";
import { TeacherLayout } from "./components/TeacherLayout";
import { AdminLayout } from "./components/AdminLayout";
import { Home } from "./pages/Home";
import { Dashboard } from "./pages/Dashboard";
import { CoursePlayer } from "./pages/CoursePlayer";
import { TestWindow } from "./pages/TestWindow";
import { Analytics } from "./pages/Analytics";
import { NotFound } from "./pages/NotFound";
import { TeacherDashboard } from "./pages/teacher/TeacherDashboard";
import { CourseManagement } from "./pages/teacher/CourseManagement";
import { StudentManagement as TeacherStudentManagement } from "./pages/teacher/StudentManagement";
import { AdminDashboard } from "./pages/admin/AdminDashboard";
import { TeacherManagement } from "./pages/admin/TeacherManagement";
import { StudentManagement } from "./pages/admin/StudentManagement";
import { DocumentManagement } from "./pages/admin/DocumentManagement";
import { AttendanceManagement } from "./pages/admin/AttendanceManagement";
import { TestScheduling } from "./pages/admin/TestScheduling";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <Home />,
  },
  {
    path: "/student",
    Component: DashboardLayout,
    children: [
      { index: true, Component: Dashboard },
      { path: "course/:courseId", Component: CoursePlayer },
      { path: "test/:testId", Component: TestWindow },
      { path: "analytics", Component: Analytics },
    ],
  },
  {
    path: "/teacher",
    Component: TeacherLayout,
    children: [
      { index: true, Component: TeacherDashboard },
      { path: "courses", Component: CourseManagement },
      { path: "students", Component: TeacherStudentManagement },
      { path: "analytics", Component: Analytics },
    ],
  },
  {
    path: "/admin",
    Component: AdminLayout,
    children: [
      { index: true, Component: AdminDashboard },
      { path: "teachers", Component: TeacherManagement },
      { path: "students", Component: StudentManagement },
      { path: "documents", Component: DocumentManagement },
      { path: "attendance", Component: AttendanceManagement },
      { path: "tests", Component: TestScheduling },
    ],
  },
  {
    path: "*",
    Component: NotFound,
  },
]);