// src/app/router.tsx
// STUB: full routing implemented in Phase 4 & 5
// Phase 0 — placeholder route only
import { BrowserRouter, Routes, Route } from "react-router-dom";

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<div>Vendor Hub — Phase 0 placeholder</div>} />
      </Routes>
    </BrowserRouter>
  );
}
