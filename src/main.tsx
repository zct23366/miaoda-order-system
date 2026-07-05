import { createRoot } from "react-dom/client";
import { HelmetProvider } from "react-helmet-async";
import { TooltipProvider } from "@/components/ui/tooltip";
import App from "./App.tsx";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <HelmetProvider>
    <TooltipProvider>
      <App />
    </TooltipProvider>
  </HelmetProvider>
);
