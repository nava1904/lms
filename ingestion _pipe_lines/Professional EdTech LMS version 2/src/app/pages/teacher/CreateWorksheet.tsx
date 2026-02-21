import { useNavigate } from "react-router";
import { WorksheetCreationWizard } from "../../design-system/organisms/WorksheetCreationWizard";

export function CreateWorksheet() {
  const navigate = useNavigate();

  const handleComplete = (data: any) => {
    console.log("Worksheet created:", data);
    // In a real app, you would save this to a backend
    alert("Worksheet published successfully!");
    navigate("/teacher/courses");
  };

  const handleCancel = () => {
    navigate("/teacher/courses");
  };

  return <WorksheetCreationWizard onComplete={handleComplete} onCancel={handleCancel} />;
}
