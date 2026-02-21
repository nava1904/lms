import { Outlet } from "react-router";
import { AdminSidebar } from "./AdminSidebar";
import { RoleSwitcher } from "./RoleSwitcher";

export function AdminLayout() {
  return (
    <div className="flex min-h-screen bg-background">
      <AdminSidebar />
      <main className="flex-1 ml-64">
        <Outlet />
      </main>
      <RoleSwitcher />
    </div>
  );
}