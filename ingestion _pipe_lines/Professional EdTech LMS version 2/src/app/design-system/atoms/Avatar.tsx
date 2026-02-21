import { cn } from "../../components/ui/utils";
import { User } from "lucide-react";

interface AvatarProps {
  src?: string;
  alt?: string;
  fallback?: string;
  size?: "sm" | "md" | "lg" | "xl";
  className?: string;
}

export function Avatar({ src, alt = "", fallback, size = "md", className }: AvatarProps) {
  const sizes = {
    sm: "w-8 h-8 text-xs",
    md: "w-10 h-10 text-sm",
    lg: "w-12 h-12 text-base",
    xl: "w-16 h-16 text-lg",
  };

  const getInitials = () => {
    if (fallback) {
      return fallback
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2);
    }
    return "";
  };

  return (
    <div
      className={cn(
        "relative inline-flex items-center justify-center rounded-full bg-primary/10 text-primary font-medium overflow-hidden",
        sizes[size],
        className
      )}
    >
      {src ? (
        <img src={src} alt={alt} className="w-full h-full object-cover" />
      ) : fallback ? (
        <span>{getInitials()}</span>
      ) : (
        <User className="w-1/2 h-1/2" />
      )}
    </div>
  );
}