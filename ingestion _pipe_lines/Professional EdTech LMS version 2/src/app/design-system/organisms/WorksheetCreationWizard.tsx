import { useState } from "react";
import { ChevronRight, ChevronLeft, Plus, Trash2, Check } from "lucide-react";
import { Button } from "../../components/ui/button";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Textarea } from "../../components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../../components/ui/select";
import { Badge } from "../atoms/Badge";
import { cn } from "../../components/ui/utils";

interface Question {
  id: string;
  text: string;
  options: string[];
  correctAnswer: number;
  marks: number;
}

interface WorksheetWizardProps {
  onComplete: (data: any) => void;
  onCancel: () => void;
}

export function WorksheetCreationWizard({ onComplete, onCancel }: WorksheetWizardProps) {
  const [currentStep, setCurrentStep] = useState(1);
  const [worksheetData, setWorksheetData] = useState({
    title: "",
    description: "",
    duration: "",
    totalMarks: 0,
    assignTo: "all",
    dueDate: "",
  });
  const [questions, setQuestions] = useState<Question[]>([
    { id: "1", text: "", options: ["", "", "", ""], correctAnswer: 0, marks: 1 },
  ]);

  const steps = [
    { id: 1, label: "Basic Info", description: "Worksheet details" },
    { id: 2, label: "Questions", description: "Add questions" },
    { id: 3, label: "Assign", description: "Assign to students" },
    { id: 4, label: "Review", description: "Final review" },
  ];

  const addQuestion = () => {
    setQuestions([
      ...questions,
      {
        id: Date.now().toString(),
        text: "",
        options: ["", "", "", ""],
        correctAnswer: 0,
        marks: 1,
      },
    ]);
  };

  const removeQuestion = (id: string) => {
    setQuestions(questions.filter((q) => q.id !== id));
  };

  const updateQuestion = (id: string, field: string, value: any) => {
    setQuestions(
      questions.map((q) => (q.id === id ? { ...q, [field]: value } : q))
    );
  };

  const updateOption = (questionId: string, optionIndex: number, value: string) => {
    setQuestions(
      questions.map((q) => {
        if (q.id === questionId) {
          const newOptions = [...q.options];
          newOptions[optionIndex] = value;
          return { ...q, options: newOptions };
        }
        return q;
      })
    );
  };

  const calculateTotalMarks = () => {
    return questions.reduce((total, q) => total + (q.marks || 0), 0);
  };

  const handleNext = () => {
    if (currentStep < 4) setCurrentStep(currentStep + 1);
  };

  const handlePrev = () => {
    if (currentStep > 1) setCurrentStep(currentStep - 1);
  };

  const handleComplete = () => {
    onComplete({ ...worksheetData, questions, totalMarks: calculateTotalMarks() });
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-5xl mx-auto py-8 px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-foreground mb-2 font-['Outfit']">
            Create New Worksheet
          </h1>
          <p className="text-muted-foreground">Follow the steps to create and assign a worksheet</p>
        </div>

        {/* Step Indicator */}
        <div className="bg-white rounded-xl border border-border p-6 mb-6">
          <div className="flex items-center justify-between">
            {steps.map((step, index) => (
              <div key={step.id} className="flex items-center flex-1">
                <div className="flex flex-col items-center flex-1">
                  <div
                    className={cn(
                      "w-12 h-12 rounded-full flex items-center justify-center font-semibold transition-colors mb-2",
                      currentStep >= step.id
                        ? "bg-primary text-white"
                        : "bg-accent text-muted-foreground"
                    )}
                  >
                    {currentStep > step.id ? <Check className="w-6 h-6" /> : step.id}
                  </div>
                  <div className="text-center">
                    <p className="font-medium text-sm">{step.label}</p>
                    <p className="text-xs text-muted-foreground">{step.description}</p>
                  </div>
                </div>
                {index < steps.length - 1 && (
                  <div
                    className={cn(
                      "h-1 flex-1 mx-4 rounded transition-colors",
                      currentStep > step.id ? "bg-primary" : "bg-accent"
                    )}
                  />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Step Content */}
        <div className="bg-white rounded-xl border border-border p-8 mb-6 min-h-[500px]">
          {/* Step 1: Basic Info */}
          {currentStep === 1 && (
            <div className="space-y-6">
              <h2 className="text-2xl font-semibold font-['Outfit']">Basic Information</h2>
              <div className="space-y-4">
                <div>
                  <Label htmlFor="title">Worksheet Title *</Label>
                  <Input
                    id="title"
                    value={worksheetData.title}
                    onChange={(e) =>
                      setWorksheetData({ ...worksheetData, title: e.target.value })
                    }
                    placeholder="e.g., Newton's Laws Practice Quiz"
                  />
                </div>
                <div>
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    value={worksheetData.description}
                    onChange={(e) =>
                      setWorksheetData({ ...worksheetData, description: e.target.value })
                    }
                    placeholder="Brief description of the worksheet"
                    rows={4}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="duration">Duration (minutes)</Label>
                    <Input
                      id="duration"
                      type="number"
                      value={worksheetData.duration}
                      onChange={(e) =>
                        setWorksheetData({ ...worksheetData, duration: e.target.value })
                      }
                      placeholder="60"
                    />
                  </div>
                  <div>
                    <Label htmlFor="dueDate">Due Date</Label>
                    <Input
                      id="dueDate"
                      type="date"
                      value={worksheetData.dueDate}
                      onChange={(e) =>
                        setWorksheetData({ ...worksheetData, dueDate: e.target.value })
                      }
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Step 2: Questions */}
          {currentStep === 2 && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-semibold font-['Outfit']">Add Questions</h2>
                  <p className="text-sm text-muted-foreground mt-1">
                    Total Marks: {calculateTotalMarks()} | {questions.length} Question(s)
                  </p>
                </div>
                <Button onClick={addQuestion} variant="outline" className="gap-2">
                  <Plus className="w-4 h-4" />
                  Add Question
                </Button>
              </div>

              <div className="space-y-6">
                {questions.map((question, index) => (
                  <div
                    key={question.id}
                    className="border border-border rounded-lg p-6 space-y-4"
                  >
                    <div className="flex items-start justify-between">
                      <Badge variant="info">Question {index + 1}</Badge>
                      {questions.length > 1 && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => removeQuestion(question.id)}
                        >
                          <Trash2 className="w-4 h-4 text-destructive" />
                        </Button>
                      )}
                    </div>

                    <div>
                      <Label>Question Text *</Label>
                      <Textarea
                        value={question.text}
                        onChange={(e) => updateQuestion(question.id, "text", e.target.value)}
                        placeholder="Enter your question"
                        rows={3}
                      />
                    </div>

                    <div className="space-y-3">
                      <Label>Options *</Label>
                      {question.options.map((option, optionIndex) => (
                        <div key={optionIndex} className="flex items-center gap-3">
                          <input
                            type="radio"
                            checked={question.correctAnswer === optionIndex}
                            onChange={() =>
                              updateQuestion(question.id, "correctAnswer", optionIndex)
                            }
                            className="w-4 h-4 text-primary"
                          />
                          <Input
                            value={option}
                            onChange={(e) =>
                              updateOption(question.id, optionIndex, e.target.value)
                            }
                            placeholder={`Option ${String.fromCharCode(65 + optionIndex)}`}
                          />
                        </div>
                      ))}
                      <p className="text-xs text-muted-foreground">
                        Select the radio button for the correct answer
                      </p>
                    </div>

                    <div className="w-32">
                      <Label>Marks</Label>
                      <Input
                        type="number"
                        value={question.marks}
                        onChange={(e) =>
                          updateQuestion(question.id, "marks", parseInt(e.target.value) || 0)
                        }
                        min="1"
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Step 3: Assign */}
          {currentStep === 3 && (
            <div className="space-y-6">
              <h2 className="text-2xl font-semibold font-['Outfit']">Assign Worksheet</h2>
              <div className="space-y-4">
                <div>
                  <Label htmlFor="assignTo">Assign To</Label>
                  <Select
                    value={worksheetData.assignTo}
                    onValueChange={(value) =>
                      setWorksheetData({ ...worksheetData, assignTo: value })
                    }
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Students</SelectItem>
                      <SelectItem value="physics-1">Advanced Physics Class</SelectItem>
                      <SelectItem value="physics-2">Quantum Mechanics Class</SelectItem>
                      <SelectItem value="individual">Select Individual Students</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="bg-accent/30 rounded-lg p-6">
                  <h3 className="font-semibold mb-3">Students who will receive this worksheet:</h3>
                  <div className="flex flex-wrap gap-2">
                    {worksheetData.assignTo === "all" ? (
                      <Badge variant="info">All Enrolled Students (247)</Badge>
                    ) : (
                      <Badge variant="info">87 Students</Badge>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Step 4: Review */}
          {currentStep === 4 && (
            <div className="space-y-6">
              <h2 className="text-2xl font-semibold font-['Outfit']">Review & Publish</h2>

              <div className="space-y-4">
                <div className="bg-accent/30 rounded-lg p-6">
                  <h3 className="font-semibold mb-4">Worksheet Summary</h3>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm text-muted-foreground">Title</p>
                      <p className="font-medium">{worksheetData.title || "Untitled"}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Duration</p>
                      <p className="font-medium">{worksheetData.duration || "—"} minutes</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Total Questions</p>
                      <p className="font-medium">{questions.length}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Total Marks</p>
                      <p className="font-medium">{calculateTotalMarks()}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Due Date</p>
                      <p className="font-medium">{worksheetData.dueDate || "Not set"}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Assigned To</p>
                      <p className="font-medium">
                        {worksheetData.assignTo === "all" ? "All Students" : "Selected Class"}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-sm text-green-800">
                    ✓ Ready to publish! Students will be notified immediately after publishing.
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Navigation Buttons */}
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={onCancel}>
            Cancel
          </Button>
          <div className="flex gap-3">
            {currentStep > 1 && (
              <Button variant="outline" onClick={handlePrev} className="gap-2">
                <ChevronLeft className="w-4 h-4" />
                Previous
              </Button>
            )}
            {currentStep < 4 ? (
              <Button onClick={handleNext} className="gap-2 bg-primary">
                Next
                <ChevronRight className="w-4 h-4" />
              </Button>
            ) : (
              <Button onClick={handleComplete} className="gap-2 bg-primary">
                <Check className="w-4 h-4" />
                Publish Worksheet
              </Button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
