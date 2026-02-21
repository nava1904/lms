import { Star } from "lucide-react";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { ImageWithFallback } from "./figma/ImageWithFallback";

interface CourseCardProps {
  id: string;
  title: string;
  instructor: string;
  image: string;
  category: string;
  rating: number;
  price: string;
  enrolled?: boolean;
}

export function CourseCard({
  id,
  title,
  instructor,
  image,
  category,
  rating,
  price,
  enrolled = false,
}: CourseCardProps) {
  return (
    <div className="bg-white rounded-xl overflow-hidden shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border hover:shadow-[0_10px_30px_rgba(0,0,0,0.08)] transition-shadow">
      {/* Image */}
      <div className="relative aspect-video overflow-hidden">
        <ImageWithFallback
          src={image}
          alt={title}
          className="w-full h-full object-cover"
        />
        <Badge className="absolute top-3 left-3 bg-primary text-primary-foreground">
          {category}
        </Badge>
      </div>

      {/* Content */}
      <div className="p-4">
        <h3 className="font-semibold text-lg text-foreground mb-1 line-clamp-2">{title}</h3>
        <p className="text-sm text-muted-foreground mb-4">{instructor}</p>

        {/* Footer */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1">
            <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
            <span className="text-sm font-medium text-foreground">{rating}</span>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-lg font-semibold text-primary font-['Outfit']">{price}</span>
            <Button
              size="sm"
              className="bg-primary hover:bg-primary/90 text-primary-foreground"
              onClick={() => window.location.href = `/student/course/${id}`}
            >
              {enrolled ? "Continue" : "Enroll Now"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}