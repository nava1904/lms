import { useNavigate, useLocation } from "react-router";
import { GraduationCap, Users, Shield } from "lucide-react";
import { Button } from "./ui/button";

export function RoleSwitcher() {
  const navigate = useNavigate();
  const location = useLocation();

  const getCurrentRole = () => {
    if (location.pathname.startsWith("/teacher")) return "teacher";
    if (location.pathname.startsWith("/admin")) return "admin";
    if (location.pathname.startsWith("/student")) return "student";
    return "none";
  };

  const currentRole = getCurrentRole();

  // Don't show on home page
  if (currentRole === "none") return null;

  return (
    <div className="fixed bottom-6 right-6 z-50">
      <div className="bg-white rounded-xl shadow-[0_10px_40px_rgba(0,0,0,0.15)] border border-border p-3">
        <p className="text-xs text-muted-foreground mb-3 px-2">Switch Role (Demo)</p>
        <div className="flex gap-2">
          <Button
            variant={currentRole === "student" ? "default" : "outline"}
            size="sm"
            onClick={() => navigate("/student")}
            className={currentRole === "student" ? "bg-primary" : ""}
          >
            <GraduationCap className="w-4 h-4 mr-2" />
            Student
          </Button>
          <Button
            variant={currentRole === "teacher" ? "default" : "outline"}
            size="sm"
            onClick={() => navigate("/teacher")}
            className={currentRole === "teacher" ? "bg-primary" : ""}
          >
            <Users className="w-4 h-4 mr-2" />
            Teacher
          </Button>
          <Button
            variant={currentRole === "admin" ? "default" : "outline"}
            size="sm"
            onClick={() => navigate("/admin")}
            className={currentRole === "admin" ? "bg-primary" : ""}
          >
            <Shield className="w-4 h-4 mr-2" />
            Admin
          </Button>
        </div>
      </div>
    </div>
  );
}