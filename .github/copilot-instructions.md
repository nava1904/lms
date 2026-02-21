# PROJECT CONTEXT: Professional LMS Migration
- **Framework**: Vyuh (Flutter) -> strictly feature-based (`feature_lms`).
- **Backend**: Sanity.io (Schemas provided in `schemaTypes/`).
- **Visual Reference**: React/Tailwind codebase in `Professional EdTech LMS Design/`.

# TRANSLATION RULES (React -> Flutter)
1. **Components**:
   - React `Sidebar.tsx` -> Flutter `NavigationRail` or `Drawer`.
   - React `Card.tsx` -> Flutter `Container` with `BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [...])`.
   - Tailwind `bg-slate-50` -> Flutter `Color(0xFFF8FAFC)`.
   - Tailwind `text-blue-600` -> Flutter `Color(0xFF2563EB)`.

2. **Data Fetching**:
   - React `useEffect(fetch...)` -> Flutter `FutureBuilder` or `SanityContentProvider`.
   - NEVER use HTTP calls directly. Use `SanityClientHelper` (which wraps `sanityClient`).

3. **Vyuh Architecture**:
   - Every screen must be a route in `lms_routes.dart`.
   - Do not use `Navigator.push`. Use `vyuh.router.go()`.