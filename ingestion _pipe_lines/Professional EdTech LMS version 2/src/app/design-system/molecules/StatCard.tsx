import { LucideIcon, TrendingUp, TrendingDown } from "lucide-react";
import { cn } from "../../components/ui/utils";

interface StatCardProps {
  icon: LucideIcon;
  label: string;
  value: string | number;
  change?: {
    value: number;
    trend: "up" | "down";
  };
  iconBgColor?: string;
  miniChart?: React.ReactNode;
}

export function StatCard({
  icon: Icon,
  label,
  value,
  change,
  iconBgColor = "bg-blue-50",
  miniChart,
}: StatCardProps) {
  const getTrendColor = () => {
    if (!change) return "";
    return change.trend === "up" ? "text-emerald-600" : "text-red-600";
  };

  const TrendIcon = change?.trend === "up" ? TrendingUp : TrendingDown;

  return (
    <div className="bg-white rounded-xl p-6 shadow-[0_2px_8px_rgba(0,0,0,0.04)] border border-border hover:shadow-[0_4px_12px_rgba(0,0,0,0.08)] transition-shadow">
      <div className="flex items-start justify-between mb-4">
        <div className={cn("p-3 rounded-lg", iconBgColor)}>
          <Icon className="w-5 h-5 text-primary" />
        </div>
        {change && (
          <div className={cn("flex items-center gap-1 text-sm font-medium", getTrendColor())}>
            <TrendIcon className="w-4 h-4" />
            <span>{Math.abs(change.value)}%</span>
          </div>
        )}
      </div>

      <div>
        <p className="text-sm text-muted-foreground mb-1">{label}</p>
        <p className="text-3xl font-semibold text-foreground font-['Outfit']">{value}</p>
      </div>

      {miniChart && <div className="mt-4">{miniChart}</div>}
    </div>
  );
}