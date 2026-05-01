---
name: responsive-design
description: >
  Expert-level responsive design patterns focusing on 2026 standards (Container Queries, 
  Fluid Typography, Mobile-First) while strictly following the user's design lead.
metadata:
  author: Local Scaffold
  version: "1.0"
---

## Core Principles

- **User-Led Design**: Never make final design decisions (colors, layouts, themes) without explicit user direction or presenting options first.
- **Container Queries First**: Prioritize `@container` over `@media` for component-level responsiveness.
- **Fluid Typography**: Use `clamp()` and relative units (`rem`, `em`, `cqi`) for seamless scaling.
- **Mobile-First**: Build for the smallest screens first and enhance for larger displays.

## Responsive Patterns

### 1. Fluid Typography
```css
h1 {
  font-size: clamp(1.5rem, 5vw + 1rem, 3rem);
}
```

### 2. Container Queries (The 2026 Standard)
```css
.card-container {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card {
    display: flex;
    gap: 1rem;
  }
}
```

### 3. Modern Layouts
- Use CSS Grid for complex 2D layouts.
- Use Flexbox for 1D alignment.
- Always check for "Safe Areas" on mobile/foldable devices.
