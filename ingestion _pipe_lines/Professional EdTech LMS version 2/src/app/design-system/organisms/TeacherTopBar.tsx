import { Search, Bell, Settings } from "lucide-react";
import { Avatar } from "../atoms/Avatar";
import { Badge } from "../atoms/Badge";
import { Button } from "../../components/ui/button";
import { Input } from "../../components/ui/input";

interface TeacherTopBarProps {
  teacherName: string;
  teacherAvatar?: string;
  notificationCount?: number;
  onSearch?: (query: string) => void;
}

export function TeacherTopBar({
  teacherName,
  teacherAvatar,
  notificationCount = 0,
  onSearch,
}: TeacherTopBarProps) {
  return (
    <div className="bg-white border-b border-border px-8 py-4">
      <div className="flex items-center justify-between">
        {/* Search */}
        <div className="flex-1 max-w-md">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              type="text"
              placeholder="Search students, classes, worksheets..."
              className="pl-10 bg-accent/50 border-transparent focus:border-primary"
              onChange={(e) => onSearch?.(e.target.value)}
            />
          </div>
        </div>

        {/* Right Section */}
        <div className="flex items-center gap-4">
          {/* Notifications */}
          <Button variant="ghost" size="sm" className="relative">
            <Bell className="w-5 h-5" />
            {notificationCount > 0 && (
              <span className="absolute -top-1 -right-1 w-5 h-5 bg-danger text-white text-xs rounded-full flex items-center justify-center">
                {notificationCount > 9 ? "9+" : notificationCount}
              </span>
            )}
          </Button>

          {/* Settings */}
          <Button variant="ghost" size="sm">
            <Settings className="w-5 h-5" />
          </Button>

          {/* Profile */}
          <div className="flex items-center gap-3 pl-4 border-l border-border">
            <div className="text-right">
              <p className="text-sm font-medium text-foreground">{teacherName}</p>
              <p className="text-xs text-muted-foreground">Teacher</p>
            </div>
            <Avatar src={teacherAvatar} fallback={teacherName} size="md" />
          </div>
        </div>
      </div>
    </div>
  );
}
