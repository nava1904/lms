import { useState, useEffect } from "react";
import { Clock, User } from "lucide-react";
import { RadioGroup, RadioGroupItem } from "../components/ui/radio-group";
import { Label } from "../components/ui/label";
import { Button } from "../components/ui/button";

interface Question {
  id: number;
  text: string;
  options: string[];
}

const questions: Question[] = [
  {
    id: 1,
    text: "A body of mass m is moving with velocity v. What is its kinetic energy?",
    options: ["½mv", "mv²", "½mv²", "2mv²"],
  },
  {
    id: 2,
    text: "Newton's first law states that an object will remain at rest or in uniform motion unless acted upon by:",
    options: ["A balanced force", "An external force", "Gravity", "Friction"],
  },
  {
    id: 3,
    text: "The SI unit of force is:",
    options: ["Joule", "Newton", "Watt", "Pascal"],
  },
  {
    id: 4,
    text: "If the displacement of a particle is given by x = t³ - 6t² + 9t + 4, the velocity at t = 2s is:",
    options: ["-3 m/s", "0 m/s", "3 m/s", "6 m/s"],
  },
  {
    id: 5,
    text: "The coefficient of friction depends on:",
    options: ["Area of contact", "Nature of surfaces", "Normal reaction", "Applied force"],
  },
];

type AnswerStatus = "answered" | "not-answered" | "marked";

export function TestWindow() {
  const [currentQuestion, setCurrentQuestion] = useState(1);
  const [answers, setAnswers] = useState<Record<number, string>>({});
  const [marked, setMarked] = useState<Set<number>>(new Set());
  const [timeLeft, setTimeLeft] = useState(3600); // 60 minutes in seconds

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours.toString().padStart(2, "0")}:${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  };

  const getQuestionStatus = (qNum: number): AnswerStatus => {
    if (marked.has(qNum)) return "marked";
    if (answers[qNum]) return "answered";
    return "not-answered";
  };

  const handleAnswer = (value: string) => {
    setAnswers((prev) => ({ ...prev, [currentQuestion]: value }));
  };

  const handleMark = () => {
    setMarked((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(currentQuestion)) {
        newSet.delete(currentQuestion);
      } else {
        newSet.add(currentQuestion);
      }
      return newSet;
    });
  };

  const currentQuestionData = questions[currentQuestion - 1];

  return (
    <div className="h-screen flex flex-col bg-white">
      {/* Header */}
      <header className="h-16 border-b border-border flex items-center justify-between px-8 bg-white shadow-sm">
        <div className="flex items-center gap-4">
          <h1 className="text-xl font-semibold font-['Outfit']">NTA Physics Exam 2026</h1>
        </div>
        <div className="flex items-center gap-6">
          <div className="flex items-center gap-2 bg-accent px-4 py-2 rounded-lg">
            <Clock className="w-5 h-5 text-primary" />
            <span className={`font-mono font-semibold ${timeLeft < 300 ? "text-destructive" : "text-foreground"}`}>
              {formatTime(timeLeft)}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <User className="w-5 h-5 text-muted-foreground" />
            <span className="text-sm font-medium">John Doe</span>
          </div>
        </div>
      </header>

      <div className="flex flex-1 overflow-hidden">
        {/* Left Panel - Question Area */}
        <div className="flex-1 overflow-y-auto p-8">
          <div className="max-w-4xl mx-auto">
            <div className="mb-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-sm font-medium text-muted-foreground">
                  Question {currentQuestion} of {questions.length}
                </h2>
                <Button
                  variant={marked.has(currentQuestion) ? "default" : "outline"}
                  size="sm"
                  onClick={handleMark}
                  className={marked.has(currentQuestion) ? "bg-purple-600 hover:bg-purple-700" : ""}
                >
                  {marked.has(currentQuestion) ? "Unmark" : "Mark for Review"}
                </Button>
              </div>
              <div className="bg-accent/30 p-6 rounded-xl border border-border">
                <p className="text-lg text-foreground leading-relaxed">{currentQuestionData.text}</p>
              </div>
            </div>

            {/* Options */}
            <div className="space-y-3">
              <RadioGroup value={answers[currentQuestion] || ""} onValueChange={handleAnswer}>
                {currentQuestionData.options.map((option, index) => (
                  <div
                    key={index}
                    className={`flex items-center space-x-3 p-4 rounded-lg border-2 transition-colors cursor-pointer ${
                      answers[currentQuestion] === option
                        ? "border-primary bg-primary/5"
                        : "border-border hover:border-primary/50 hover:bg-accent/50"
                    }`}
                  >
                    <RadioGroupItem value={option} id={`option-${index}`} />
                    <Label
                      htmlFor={`option-${index}`}
                      className="flex-1 cursor-pointer text-base font-normal"
                    >
                      {option}
                    </Label>
                  </div>
                ))}
              </RadioGroup>
            </div>

            {/* Navigation Buttons */}
            <div className="flex justify-between mt-8 pt-6 border-t border-border">
              <Button
                variant="outline"
                onClick={() => setCurrentQuestion((prev) => Math.max(1, prev - 1))}
                disabled={currentQuestion === 1}
              >
                Previous
              </Button>
              <div className="flex gap-3">
                <Button
                  variant="outline"
                  onClick={() => {
                    setAnswers((prev) => {
                      const newAnswers = { ...prev };
                      delete newAnswers[currentQuestion];
                      return newAnswers;
                    });
                  }}
                >
                  Clear Response
                </Button>
                {currentQuestion < questions.length ? (
                  <Button
                    onClick={() => setCurrentQuestion((prev) => Math.min(questions.length, prev + 1))}
                    className="bg-primary hover:bg-primary/90"
                  >
                    Save & Next
                  </Button>
                ) : (
                  <Button className="bg-green-600 hover:bg-green-700">Submit Test</Button>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Right Panel - Question Palette */}
        <div className="w-80 border-l border-border bg-accent/20 p-6 overflow-y-auto">
          <h3 className="font-semibold mb-4 font-['Outfit']">Question Palette</h3>

          <div className="grid grid-cols-5 gap-2 mb-6">
            {Array.from({ length: questions.length }, (_, i) => i + 1).map((num) => {
              const status = getQuestionStatus(num);
              return (
                <button
                  key={num}
                  onClick={() => setCurrentQuestion(num)}
                  className={`aspect-square rounded-lg flex items-center justify-center font-medium text-sm transition-colors ${
                    currentQuestion === num
                      ? "ring-2 ring-primary ring-offset-2"
                      : ""
                  } ${
                    status === "answered"
                      ? "bg-green-600 text-white hover:bg-green-700"
                      : status === "marked"
                      ? "bg-purple-600 text-white hover:bg-purple-700"
                      : "bg-white text-foreground border-2 border-border hover:border-primary"
                  }`}
                >
                  {num}
                </button>
              );
            })}
          </div>

          {/* Legend */}
          <div className="space-y-3 p-4 bg-white rounded-lg border border-border">
            <h4 className="text-sm font-semibold mb-3">Legend</h4>
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded bg-green-600"></div>
              <span className="text-xs text-muted-foreground">Answered</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded bg-white border-2 border-border"></div>
              <span className="text-xs text-muted-foreground">Not Answered</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded bg-purple-600"></div>
              <span className="text-xs text-muted-foreground">Marked for Review</span>
            </div>
          </div>

          {/* Summary */}
          <div className="mt-6 p-4 bg-white rounded-lg border border-border">
            <h4 className="text-sm font-semibold mb-3">Summary</h4>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Answered:</span>
                <span className="font-medium">{Object.keys(answers).length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Not Answered:</span>
                <span className="font-medium">{questions.length - Object.keys(answers).length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Marked:</span>
                <span className="font-medium">{marked.size}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
