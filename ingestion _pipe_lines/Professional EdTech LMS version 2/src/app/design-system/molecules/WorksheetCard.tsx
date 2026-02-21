import { Calendar, Users, TrendingUp, MoreVertical, FileText } from "lucide-react";
import { Badge } from "../atoms/Badge";
import { Button } from "../../components/ui/button";

interface WorksheetCardProps {
  id: string;
  title: string;
  assignedTo: string;
  dueDate: string;
  submissionCount: number;
  totalStudents: number;
  avgScore?: number;
  status?: "draft" | "active" | "completed";
  onEdit?: (id: string) => void;
}

export function WorksheetCard({
  id,
  title,
  assignedTo,
  dueDate,
  submissionCount,
  totalStudents,
  avgScore,
  status = "active",
  onEdit,
}: WorksheetCardProps) {
  const getStatusBadge = () => {
    if (status === "draft") return <Badge variant="default">Draft</Badge>;
    if (status === "completed") return <Badge variant="success">Completed</Badge>;
    return <Badge variant="info">Active</Badge>;
  };

  const submissionPercentage = (submissionCount / totalStudents) * 100;

  return (
    <div className="bg-white border border-border rounded-xl p-5 hover:shadow-lg transition-all duration-200 group">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-start gap-3">
          <div className="p-2 bg-primary/10 rounded-lg">
            <FileText className="w-5 h-5 text-primary" />
          </div>
          <div>
            <h3 className="font-semibold text-lg mb-1 group-hover:text-primary transition-colors">
              {title}
            </h3>
            {getStatusBadge()}
          </div>
        </div>

        <Button variant="ghost" size="sm" onClick={() => onEdit?.(id)}>
          <MoreVertical className="w-4 h-4" />
        </Button>
      </div>

      <div className="space-y-3">
        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-2 text-muted-foreground">
            <Users className="w-4 h-4" />
            <span>Assigned to</span>
          </div>
          <span className="font-medium text-foreground">{assignedTo}</span>
        </div>

        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-2 text-muted-foreground">
            <Calendar className="w-4 h-4" />
            <span>Due Date</span>
          </div>
          <span className="font-medium text-foreground">{dueDate}</span>
        </div>

        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-2 text-muted-foreground">
            <FileText className="w-4 h-4" />
            <span>Submissions</span>
          </div>
          <span className="font-medium text-foreground">
            {submissionCount}/{totalStudents}
          </span>
        </div>

        {avgScore !== undefined && (
          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <TrendingUp className="w-4 h-4" />
              <span>Avg. Score</span>
            </div>
            <span className="font-medium text-foreground">{avgScore}%</span>
          </div>
        )}
      </div>

      <div className="mt-4 pt-4 border-t border-border">
        <div className="flex items-center justify-between text-xs text-muted-foreground mb-2">
          <span>Submission Progress</span>
          <span>{Math.round(submissionPercentage)}%</span>
        </div>
        <div className="w-full bg-accent h-2 rounded-full overflow-hidden">
          <div
            className="bg-primary h-full transition-all duration-300"
            style={{ width: `${submissionPercentage}%` }}
          />
        </div>
      </div>
    </div>
  );
}
