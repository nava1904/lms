import { Outlet } from "react-router";
import { TeacherSidebar } from "./TeacherSidebar";
import { RoleSwitcher } from "./RoleSwitcher";

export function TeacherLayout() {
  return (
    <div className="flex min-h-screen bg-background">
      <TeacherSidebar />
      <main className="flex-1 ml-64">
        <Outlet />
      </main>
      <RoleSwitcher />
    </div>
  );
}