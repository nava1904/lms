import { useNavigate } from "react-router";
import { Home, AlertCircle } from "lucide-react";
import { Button } from "../components/ui/button";

export function NotFound() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="text-center">
        <AlertCircle className="w-20 h-20 text-primary mx-auto mb-6" />
        <h1 className="text-6xl font-bold text-foreground mb-4 font-['Outfit']">404</h1>
        <h2 className="text-2xl font-semibold text-foreground mb-2 font-['Outfit']">Page Not Found</h2>
        <p className="text-muted-foreground mb-8 max-w-md mx-auto">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <Button
          onClick={() => navigate("/")}
          className="bg-primary hover:bg-primary/90 text-primary-foreground"
        >
          <Home className="w-4 h-4 mr-2" />
          Back to Dashboard
        </Button>
      </div>
    </div>
  );
}
