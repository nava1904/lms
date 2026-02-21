import { Users, TrendingUp, BookOpen } from "lucide-react";
import { ProgressBar } from "../atoms/ProgressBar";
import { Button } from "../../components/ui/button";
import { useNavigate } from "react-router";

interface ClassCardProps {
  id: string;
  name: string;
  subject?: string;
  studentCount: number;
  avgScore: number;
  completion: number;
  thumbnail?: string;
}

export function ClassCard({
  id,
  name,
  subject,
  studentCount,
  avgScore,
  completion,
  thumbnail,
}: ClassCardProps) {
  const navigate = useNavigate();

  return (
    <div className="bg-white rounded-xl border border-border overflow-hidden hover:shadow-lg transition-all duration-200 cursor-pointer group">
      {/* Thumbnail */}
      <div className="h-32 bg-gradient-to-br from-primary/10 to-primary/5 relative overflow-hidden">
        {thumbnail ? (
          <img src={thumbnail} alt={name} className="w-full h-full object-cover" />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <BookOpen className="w-12 h-12 text-primary/30" />
          </div>
        )}
        <div className="absolute top-3 right-3">
          <span className="bg-white/90 backdrop-blur-sm px-3 py-1 rounded-full text-xs font-medium text-foreground">
            {subject || "General"}
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="p-5">
        <h3 className="font-semibold text-lg mb-3 group-hover:text-primary transition-colors">
          {name}
        </h3>

        <div className="space-y-3 mb-4">
          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Users className="w-4 h-4" />
              <span>Students</span>
            </div>
            <span className="font-medium text-foreground">{studentCount}</span>
          </div>

          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <TrendingUp className="w-4 h-4" />
              <span>Avg. Score</span>
            </div>
            <span className="font-medium text-foreground">{avgScore}%</span>
          </div>

          <div>
            <div className="flex items-center justify-between text-sm mb-2">
              <span className="text-muted-foreground">Progress</span>
              <span className="font-medium text-foreground">{completion}%</span>
            </div>
            <ProgressBar value={completion} variant="primary" size="md" />
          </div>
        </div>

        <Button
          onClick={() => navigate(`/teacher/class/${id}`)}
          className="w-full"
          variant="outline"
        >
          View Details
        </Button>
      </div>
    </div>
  );
}
