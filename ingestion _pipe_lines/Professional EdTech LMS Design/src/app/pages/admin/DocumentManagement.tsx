import { FileText, Download, Eye, Trash2 } from "lucide-react";
import { Badge } from "../../components/ui/badge";
import { Button } from "../../components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../../components/ui/tabs";

interface Document {
  id: string;
  name: string;
  type: string;
  owner: string;
  ownerId: string;
  uploadedDate: string;
  size: string;
  category: "student" | "teacher";
}

const documents: Document[] = [
  {
    id: "1",
    name: "Student ID - John Doe.pdf",
    type: "ID",
    owner: "John Doe",
    ownerId: "STU001",
    uploadedDate: "2026-02-10",
    size: "2.4 MB",
    category: "student",
  },
  {
    id: "2",
    name: "Transcript - Emma Wilson.pdf",
    type: "Academic",
    owner: "Emma Wilson",
    ownerId: "STU002",
    uploadedDate: "2026-02-12",
    size: "1.8 MB",
    category: "student",
  },
  {
    id: "3",
    name: "Teaching Certificate - Dr. Sarah Johnson.pdf",
    type: "Certificate",
    owner: "Dr. Sarah Johnson",
    ownerId: "TCH001",
    uploadedDate: "2026-01-20",
    size: "3.2 MB",
    category: "teacher",
  },
  {
    id: "4",
    name: "ID Proof - Prof. Michael Chen.pdf",
    type: "ID",
    owner: "Prof. Michael Chen",
    ownerId: "TCH002",
    uploadedDate: "2026-01-22",
    size: "2.1 MB",
    category: "teacher",
  },
];

export function DocumentManagement() {
  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 font-['Outfit']">Document Management</h1>
          <p className="text-muted-foreground">Manage student and teacher documents</p>
        </div>

        <Tabs defaultValue="all" className="w-full">
          <TabsList className="mb-6">
            <TabsTrigger value="all">All Documents</TabsTrigger>
            <TabsTrigger value="student">Student Documents</TabsTrigger>
            <TabsTrigger value="teacher">Teacher Documents</TabsTrigger>
          </TabsList>

          <TabsContent value="all">
            <DocumentTable documents={documents} />
          </TabsContent>

          <TabsContent value="student">
            <DocumentTable documents={documents.filter((d) => d.category === "student")} />
          </TabsContent>

          <TabsContent value="teacher">
            <DocumentTable documents={documents.filter((d) => d.category === "teacher")} />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}

function DocumentTable({ documents }: { documents: Document[] }) {
  return (
    <div className="bg-white rounded-xl shadow-[0_10px_20px_rgba(0,0,0,0.03)] border border-border overflow-hidden">
      <table className="w-full">
        <thead className="bg-accent/50">
          <tr>
            <th className="text-left p-4 font-medium">Document</th>
            <th className="text-left p-4 font-medium">Type</th>
            <th className="text-left p-4 font-medium">Owner</th>
            <th className="text-left p-4 font-medium">Upload Date</th>
            <th className="text-left p-4 font-medium">Size</th>
            <th className="text-right p-4 font-medium">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {documents.map((doc) => (
            <tr key={doc.id} className="hover:bg-accent/20">
              <td className="p-4">
                <div className="flex items-center gap-3">
                  <FileText className="w-5 h-5 text-primary" />
                  <span className="font-medium">{doc.name}</span>
                </div>
              </td>
              <td className="p-4">
                <Badge variant="outline">{doc.type}</Badge>
              </td>
              <td className="p-4">
                <div>
                  <p className="font-medium">{doc.owner}</p>
                  <p className="text-xs text-muted-foreground font-mono">{doc.ownerId}</p>
                </div>
              </td>
              <td className="p-4">
                <span className="text-sm text-muted-foreground">{doc.uploadedDate}</span>
              </td>
              <td className="p-4">
                <span className="text-sm text-muted-foreground">{doc.size}</span>
              </td>
              <td className="p-4">
                <div className="flex justify-end gap-2">
                  <Button variant="ghost" size="sm">
                    <Eye className="w-4 h-4" />
                  </Button>
                  <Button variant="ghost" size="sm">
                    <Download className="w-4 h-4" />
                  </Button>
                  <Button variant="ghost" size="sm">
                    <Trash2 className="w-4 h-4 text-destructive" />
                  </Button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
