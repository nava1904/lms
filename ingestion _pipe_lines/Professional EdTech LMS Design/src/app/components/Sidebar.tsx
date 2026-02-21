import { NavLink } from "react-router";
import { LayoutDashboard, BookOpen, BarChart3, FileText, Settings } from "lucide-react";

const navItems = [
  { icon: LayoutDashboard, label: "Dashboard", to: "/student" },
  { icon: BookOpen, label: "My Courses", to: "/student/course/physics-101" },
  { icon: BarChart3, label: "Analytics", to: "/student/analytics" },
  { icon: FileText, label: "Assignments", to: "/student/test/nta-physics" },
  { icon: Settings, label: "Settings", to: "/student/settings" },
];

export function Sidebar() {
  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-white border-r border-border flex flex-col shadow-sm">
      {/* Logo */}
      <div className="h-16 flex items-center px-6 border-b border-border">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
            <BookOpen className="w-5 h-5 text-primary-foreground" />
          </div>
          <span className="font-['Outfit'] text-xl font-semibold text-foreground">LearnHub</span>
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
                      : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
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
      <div className="p-4 border-t border-border">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-blue-600 flex items-center justify-center text-white font-semibold">
            JD
          </div>
          <div className="flex-1">
            <p className="font-medium text-sm text-foreground">John Doe</p>
            <p className="text-xs text-muted-foreground">Student</p>
          </div>
        </div>
      </div>
    </aside>
  );
}