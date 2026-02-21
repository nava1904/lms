import { Avatar } from "../atoms/Avatar";
import { Badge } from "../atoms/Badge";
import { ProgressBar } from "../atoms/ProgressBar";
import { MoreVertical, Mail, UserCog } from "lucide-react";
import { Button } from "../../components/ui/button";

interface StudentRowProps {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  avgScore: number;
  completion: number;
  riskLevel?: "low" | "medium" | "high";
  onViewDetails?: (id: string) => void;
}

export function StudentRow({
  id,
  name,
  email,
  avatar,
  avgScore,
  completion,
  riskLevel,
  onViewDetails,
}: StudentRowProps) {
  const getRiskBadge = () => {
    if (!riskLevel || riskLevel === "low") return null;
    if (riskLevel === "high") return <Badge variant="danger">At Risk</Badge>;
    return <Badge variant="warning">Needs Support</Badge>;
  };

  const getScoreColor = () => {
    if (avgScore >= 80) return "text-emerald-600";
    if (avgScore >= 60) return "text-amber-600";
    return "text-red-600";
  };

  return (
    <div className="bg-white border border-border rounded-lg p-4 hover:shadow-md transition-shadow group">
      <div className="flex items-center gap-4">
        {/* Avatar & Name */}
        <Avatar src={avatar} fallback={name} size="md" />

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-medium text-foreground truncate">{name}</h4>
            {getRiskBadge()}
          </div>
          <div className="flex items-center gap-1 text-sm text-muted-foreground">
            <Mail className="w-3 h-3" />
            <span className="truncate">{email}</span>
          </div>
        </div>

        {/* Stats */}
        <div className="hidden md:flex items-center gap-8">
          <div className="text-center">
            <p className="text-xs text-muted-foreground mb-1">Avg Score</p>
            <p className={`text-lg font-semibold ${getScoreColor()}`}>{avgScore}%</p>
          </div>

          <div className="w-32">
            <p className="text-xs text-muted-foreground mb-2">Completion</p>
            <ProgressBar value={completion} variant="primary" size="sm" showLabel />
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onViewDetails?.(id)}
            className="opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <UserCog className="w-4 h-4" />
          </Button>
          <Button variant="ghost" size="sm">
            <MoreVertical className="w-4 h-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
