# Poultry PMS Desktop - Application Blueprint

## UI/UX Section: Desktop Responsiveness Standards

To ensure the Poultry PMS Desktop application remains functional and professional across all window sizes, the following standards are mandatory:

### 1. Flexible Layouts
- **No Fixed Dimensions**: Avoid hardcoding `width` and `height` for containers that represent major layout sections.
- **Proportional Sizing**: Use `Expanded`, `Flexible`, and `Spacer` inside `Row` and `Column` widgets to allow content to adapt to the available space.
- **Adaptive Padding**: Use `LayoutBuilder` to adjust padding and margins (e.g., larger padding on wide screens, tighter on narrow).

### 2. Standard Breakpoints
Use the following breakpoints for all main views:
- **Wide (> 1200px)**: Expanded Sidebar + 3-Column Grids + Side-by-side panels.
- **Medium (850px - 1200px)**: Collapsed Sidebar (Rail) + 2-Column Grids + Stacked panels.
- **Narrow (< 850px)**: Collapsed Sidebar + 1-Column Grids + Vertically stacked content.

### 3. Data Table Standards
- **Horizontal Scrolling**: All `DataTable` widgets MUST be wrapped in a `SingleChildScrollView(scrollDirection: Axis.horizontal)` and a `Scrollbar`.
- **Pinned Actions**: Ensure the "Actions" column remains accessible via horizontal scroll and has a clear visual distinction.
- **Worker Stamps**: Use compact, color-coded "Worker Stamps" (e.g., `SYS`, `VET`, `MGR`) instead of lengthy text descriptions to save horizontal space.

### 4. Window Constraints
- **Minimum Size**: All desktop builds must enforce a minimum window size of **800x600** via `window_manager` to prevent layout collapse.

### 5. Implementation Workflow
- Always wrap top-level page content in a `LayoutBuilder`.
- Use `isCompact` or `isNarrow` boolean flags derived from `constraints.maxWidth` to conditionally render UI components.
- Verify responsiveness by dragging the window edges and checking for "Yellow/Black" overflow strips.
