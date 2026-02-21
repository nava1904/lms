import { Outlet, useLocation } from "react-router";
import { Sidebar } from "./Sidebar";
import { RoleSwitcher } from "./RoleSwitcher";

export function DashboardLayout() {
  const location = useLocation();
  const isTestPage = location.pathname.includes("/test/");

  // Test page uses full screen, no sidebar
  if (isTestPage) {
    return (
      <>
        <Outlet />
        <RoleSwitcher />
      </>
    );
  }

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <main className="flex-1 ml-64">
        <Outlet />
      </main>
      <RoleSwitcher />
    </div>
  );
}