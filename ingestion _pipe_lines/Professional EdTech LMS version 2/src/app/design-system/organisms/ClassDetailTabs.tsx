import { useState } from "react";
import { Users, FileText, BookOpen, BarChart3 } from "lucide-react";
import { cn } from "../../components/ui/utils";

interface Tab {
  id: string;
  label: string;
  icon: React.ElementType;
  content: React.ReactNode;
}

interface ClassDetailTabsProps {
  tabs: Tab[];
  defaultTab?: string;
}

export function ClassDetailTabs({ tabs, defaultTab }: ClassDetailTabsProps) {
  const [activeTab, setActiveTab] = useState(defaultTab || tabs[0]?.id);

  const activeTabContent = tabs.find((tab) => tab.id === activeTab)?.content;

  return (
    <div className="bg-white rounded-xl border border-border overflow-hidden">
      {/* Tab Headers */}
      <div className="border-b border-border">
        <div className="flex">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;

            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "flex items-center gap-2 px-6 py-4 font-medium transition-all relative",
                  isActive
                    ? "text-primary bg-primary/5"
                    : "text-muted-foreground hover:text-foreground hover:bg-accent/50"
                )}
              >
                <Icon className="w-5 h-5" />
                <span>{tab.label}</span>
                {isActive && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary" />
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* Tab Content */}
      <div className="p-6">{activeTabContent}</div>
    </div>
  );
}

// Pre-built tab content components for common use cases
export function StudentsTabContent({ children }: { children: React.ReactNode }) {
  return <div className="space-y-4">{children}</div>;
}

export function WorksheetsTabContent({ children }: { children: React.ReactNode }) {
  return <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">{children}</div>;
}

export function ContentTabContent({ children }: { children: React.ReactNode }) {
  return <div className="space-y-6">{children}</div>;
}

export function AnalyticsTabContent({ children }: { children: React.ReactNode }) {
  return <div className="space-y-6">{children}</div>;
}