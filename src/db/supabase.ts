
            import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || "https://occsfgsqshrhhjkzgplz.supabase.co";
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jY3NmZ3Nxc2hyaGhqa3pncGx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNDIwMjcsImV4cCI6MjA5ODgxODAyN30.d5xReMqi84L3S0ZI2sVy2yFx1ewHzuQdb7zklNM1bRQ";

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
            