import { NavLink } from "react-router";
import { LayoutDashboard, Users, GraduationCap, FileText, Calendar, ClipboardCheck, Settings, Shield } from "lucide-react";

const navItems = [
  { icon: LayoutDashboard, label: "Dashboard", to: "/admin" },
  { icon: GraduationCap, label: "Teachers", to: "/admin/teachers" },
  { icon: Users, label: "Students", to: "/admin/students" },
  { icon: FileText, label: "Documents", to: "/admin/documents" },
  { icon: ClipboardCheck, label: "Attendance", to: "/admin/attendance" },
  { icon: Calendar, label: "Test Schedule", to: "/admin/tests" },
  { icon: Settings, label: "Settings", to: "/admin/settings" },
];

export function AdminSidebar() {
  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-slate-900 text-white flex flex-col shadow-sm">
      {/* Logo */}
      <div className="h-16 flex items-center px-6 border-b border-slate-700">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
            <Shield className="w-5 h-5 text-primary-foreground" />
          </div>
          <span className="font-['Outfit'] text-xl font-semibold">Admin Panel</span>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-6">
        <ul className="space-y-1">
          {navItems.map((item) => (
            <li key={item.to}>
              <NavLink
                to={item.to}
                className={({ isActive }) =>
                  `flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors ${
                    isActive
                      ? "bg-primary text-primary-foreground"
                      : "text-slate-300 hover:bg-slate-800 hover:text-white"
                  }`
                }
              >
                <item.icon className="w-5 h-5" />
                <span className="font-medium">{item.label}</span>
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>

      {/* User Profile */}
      <div className="p-4 border-t border-slate-700">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-indigo-600 flex items-center justify-center text-white font-semibold">
            AD
          </div>
          <div className="flex-1">
            <p className="font-medium text-sm">Admin User</p>
            <p className="text-xs text-slate-400">Administrator</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
