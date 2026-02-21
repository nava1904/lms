import { LucideIcon } from "lucide-react";

interface StatsCardProps {
  icon: LucideIcon;
  label: string;
  value: string;
  iconBgColor: string;
}

export function StatsCard({ icon: Icon, label, value, iconBgColor }: StatsCardProps) {
  return (
    <div className="bg-white rounded-xl p-6 shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border">
      <div className="flex items-center gap-4">
        <div className={`w-12 h-12 rounded-full ${iconBgColor} flex items-center justify-center`}>
          <Icon className="w-6 h-6 text-primary" />
        </div>
        <div>
          <p className="text-2xl font-semibold text-foreground font-['Outfit']">{value}</p>
          <p className="text-sm text-muted-foreground">{label}</p>
        </div>
      </div>
    </div>
  );
}
