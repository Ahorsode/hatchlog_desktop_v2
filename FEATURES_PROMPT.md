# Agent Prompt — Desktop Feature Parity (pfm-desktop)

## Context

The web app has several screens and capabilities the desktop currently does
not have. This prompt adds them. Every new screen must read exclusively from
the local SQLite database via Drift streams (`Provider.of<AppDatabase>`) —
no direct Supabase calls in screens. The sync engine handles cloud sync
separately. All new screens follow the same dark-card visual language already
used throughout the app (card color, borderRadius 24, box shadows, cs.onSurface
for text, cs.outline for borders).

---

## FEATURE 1 — Climate / Environmental Monitoring Screen

### What the web has
`/dashboard/climate` — A full-screen grid of house cards, each showing live
`currentTemperature`, `currentHumidity`, and a status badge. The web also
allows inline editing of temperature/humidity readings per house.

### What to build on desktop

**Create: `lib/screens/climate_screen.dart`**

This is a full-page screen, not a widget. It reads from the `houses` table.

**Layout:**
```
Header row:
  Title: "Climate Monitor"  Subtitle: "Environmental status per house"
  Right: last-updated timestamp (from most recently updated house row)

Body:
  StreamBuilder on (db.select(db.houses)..where((h) => h.farmId.equals(boundFarmId))).watch()
  
  If no houses → EmptyState card: "No houses registered. Add houses in the
    Houses screen to start monitoring."

  If houses found → Wrap grid (3 columns on wide, 2 on medium, 1 on narrow)
    Each house renders a ClimateHouseCard (see below)
```

**`_ClimateHouseCard` widget:**

Each card shows:
- House name (bold, large)
- Temperature badge: value in °C with a thermometer icon. Colour coding:
  - < 18°C → blue (too cold)
  - 18–32°C → green (optimal)
  - > 32°C → red (too hot)
  - null → grey "Not set"
- Humidity badge: value in % with a water-drop icon. Colour coding:
  - < 40% → amber (too dry)
  - 40–70% → green (optimal)
  - > 70% → orange (too humid)
  - null → grey "Not set"
- Overall status badge: "OPTIMAL" (green) if both in range, "ATTENTION" (amber)
  if one is out of range, "CRITICAL" (red) if both are out of range, "UNKNOWN"
  (grey) if both are null.
- An edit icon button (pencil) that opens a small inline `AlertDialog` with
  two number fields: "Temperature (°C)" and "Humidity (%)". On Save, it runs:
  ```dart
  await (db.update(db.houses)..where((h) => h.id.equals(house.id)))
      .write(HousesCompanion(
        currentTemperature: Value(tempValue),
        currentHumidity: Value(humidityValue),
      ));
  ```
  Then closes the dialog. No Supabase call — the sync engine will push it.

**Add to `main_scaffold.dart` owner config:**

Add `ClimateScreen()` to the `_pages` list.
Add to `OPERATIONS` section in `_sections`:
```dart
SidebarMenuItem(
  index: <next available index>,
  icon: Icons.thermostat_rounded,
  label: 'Climate',
),
```
Re-number all subsequent indices accordingly.

---

## FEATURE 2 — Comprehensive Reports Screen

### What the web has
`/dashboard/reports` — Calls `generateComprehensiveFarmReport()` with a
date range. Shows totals for revenue, expenses, net income, eggs, feed,
mortality per batch. Has a date range picker to regenerate.

### What to build on desktop

**Create: `lib/screens/comprehensive_report_screen.dart`**

This replaces `ReportLogScreen` in the sidebar label but keeps `ReportLogScreen`
accessible via a tab inside this new screen.

**Tabs at top of screen:**
- Tab 0: "Farm Report" (the new comprehensive report)
- Tab 1: "Operation Logs" (renders the existing `ReportLogScreen` widget body
  inlined, not as a navigation push)

**Tab 0 — Farm Report:**

Two `DatePickerButton` widgets for Start Date and End Date (default: last 30
days). A "Generate Report" button that triggers the query.

On generate, query the local SQLite for the date range:

```dart
// Revenue: sum of sales.total_amount where sale_date between start and end
// Expenses: sum of expenses.amount where date between start and end
// Eggs: sum of egg_productions.eggs_collected where log_date between start/end
// Feed: sum of feeding_logs.amount_consumed where log_date between start/end
// Mortality: sum of mortalities.count where log_date between start/end
// Net Income: revenue - expenses
// Mortality Rate: (total_mortality / starting_bird_count) * 100
// Per-batch breakdown: group all of above by batch_id
```

**Report output layout (shown after generation):**

Section 1 — Summary Cards row (6 cards):
```
Total Revenue | Total Expenses | Net Income | Total Eggs | Feed Consumed | Mortality
```
Net Income card colour: green if positive, red if negative.

Section 2 — Category breakdown (two columns):
- Revenue by category (pie or simple labelled list with amounts)
- Expenses by category (same)

Section 3 — Per-batch table:
Columns: Batch Name | Birds | Eggs | Feed (kg) | Mortality | Mortality Rate

Section 4 — Date-range trend (simple 7-interval bar chart if period > 7 days):
X axis: dates. Y axis: eggs collected. Built with plain Canvas painter or
`fl_chart` if already in `pubspec.yaml`, otherwise use a simple `CustomPainter`
bar chart — do NOT add new chart packages.

**Export button** (top right of report once generated): calls
`_exportReportAsCsv()` which builds a CSV string and writes it to
`downloads/pfm_report_YYYYMMDD.csv` using the `path_provider` package
(already in `pubspec.yaml`). Shows a success snackbar with the file path.

**Replace `ReportLogScreen` in sidebar with `ComprehensiveReportScreen`:**

In `main_scaffold.dart`, replace the existing `ReportLogScreen()` page entry
with `ComprehensiveReportScreen()`. The sidebar label becomes "Reports & Logs"
(already the current label — no sidebar change needed, just the page swap).

---

## FEATURE 3 — Egg Analytics Sub-Screen

### What the web has
`/dashboard/eggs/analytics` — 7-day and 30-day egg production totals, daily
average, production efficiency (eggs / bird), trend chart, top-performing batch.

### What to build on desktop

**Create: `lib/screens/egg_analytics_screen.dart`**

Add an "Analytics" button to `EggProductionScreen`'s header row that navigates
to `EggAnalyticsScreen` via `Navigator.push`.

**Layout of `EggAnalyticsScreen`:**

Header: Back arrow + "Egg Analytics"

Period selector row: "7 Days" | "30 Days" | "90 Days" (segmented button,
default 7 days). Changing the period re-queries.

Stats row (4 cards):
- Total Eggs in period
- Daily Average
- Production Efficiency: (totalEggs / totalBirds) formatted as "X eggs/bird"
- Best Day: date + count

Trend section: A simple bar chart using `CustomPainter`. X = each day in
the period, Y = eggs collected. Draw bars with `cs.primary` colour. Show
date labels on X axis (abbreviated: "Mon", "Tue" or "Jun 1").

Top 3 Batches table: batch name, eggs in period, daily average for that batch.

All data sourced from local SQLite:
```dart
// Query egg_productions where log_date >= periodStart
// Group by log_date for chart, group by batch_id for top batches
// Join batches to get current_count for efficiency calc
```

---

## FEATURE 4 — Feed Analytics Sub-Screen

### What the web has
`/dashboard/feed/analytics` — Total feed consumed, cost per kg, feed conversion
ratio (FCR = feed consumed / weight gain), daily average, trend chart.

### What to build on desktop

**Create: `lib/screens/feed_analytics_screen.dart`**

Add an "Analytics" button to `FeedManagementScreen`'s header row that
navigates to `FeedAnalyticsScreen` via `Navigator.push`.

**Layout:**

Period selector: 7 / 30 / 90 days (same pattern as egg analytics).

Stats row (4 cards):
- Total Feed Consumed (in kg)
- Daily Average (kg/day)
- Cost This Period (sum of related inventory purchase costs if available,
  otherwise show "N/A")
- Top Consumer (batch that consumed most feed)

Trend chart: same `CustomPainter` bar chart, one bar per day, Y = kg consumed.

Per-batch breakdown table: batch name | feed consumed (kg) | % of total.

---

## FEATURE 5 — Sales Analytics Sub-Screen

### What the web has
`/dashboard/sales/analytics` — Revenue by category, payment status matrix
(Paid / Partial / Unpaid), top customers by revenue, monthly revenue trend.

### What to build on desktop

**Create: `lib/screens/sales_analytics_screen.dart`**

Add an "Analytics" button to `SalesScreen`'s header row.

**Layout:**

Period selector: 7 / 30 / 90 days.

Stats row (4 cards):
- Total Revenue
- Total Sales Count
- Average Sale Value
- Outstanding (unpaid + partial)

Revenue by Category: a simple horizontal bar list. Each category gets a
coloured bar proportional to its share of total revenue. Labels on left,
amounts on right.

Payment Status Matrix: three rows (PAID / PARTIAL / UNPAID), showing count
and total amount for each.

Top 5 Customers table: customer name | total spent | sales count.

Revenue trend chart (CustomPainter bars): daily revenue over selected period.

All from local SQLite `sales` and `customers` tables.

---

## FEATURE 6 — Customer Account Statement

### What the web has
`/dashboard/sales/customers/[id]/statement` — Full transaction history for
one customer. Running balance. Total outstanding. Print/export.

### What to build on desktop

In `CustomerDirectoryScreen`, when a user taps a customer row, currently it
either does nothing or shows a basic detail sheet. Replace that action with
a `Navigator.push` to a new `CustomerStatementScreen`.

**Create: `lib/screens/customer_statement_screen.dart`**

Constructor: `const CustomerStatementScreen({required Customer customer})`

**Layout:**

Header:
- Back arrow
- Customer name (large, bold)
- Sub: phone, address if available

Summary strip (3 cards):
- Total Billed (sum of all sales.total_amount for this customer)
- Total Paid (sum where payment_status == 'PAID')
- Outstanding (billed - paid)
  Outstanding card: red background if > 0, green if 0.

Transaction table (scrollable):
Columns: Date | Description | Amount | Status | Balance
- Each row is one sale
- Balance column = running total of outstanding (cumulative)
- Status badge colour: PAID=green, PARTIAL=amber, UNPAID=red
- Sort by date descending

Export to CSV button in header (same pattern as report screen).

---

## FEATURE 7 — Supplier Statement

### What the web has
`/dashboard/suppliers/[id]/statement` — Same concept as customer statement
but for supplier purchase history.

### What to build on desktop

In `SupplierDirectoryScreen`, on tap of a supplier row, push to a new
`SupplierStatementScreen`.

**Create: `lib/screens/supplier_statement_screen.dart`**

Constructor: `const SupplierStatementScreen({required Supplier supplier})`

**Layout:** Mirror the customer statement layout but sourced from `expenses`
or `purchases` table (whichever table stores supplier purchases in the local DB).
Check the local DB schema before writing: look for a table with `supplier_id`
foreign key. If no such table exists, source from `inventory` items that have
a `supplier_id` column. Show purchase date, item name, quantity, unit cost,
total, payment status.

Summary: Total Purchased | Total Paid | Outstanding.

---

## FEATURE 8 — Subscription Status Badge in Sidebar

### What the web has
The web's navbar shows the farm's subscription tier (FREE / STANDARD / PREMIUM).

### What to build on desktop

In `lib/widgets/session_mode_badge.dart` (the badge shown in the sidebar),
add the subscription tier and days remaining below the existing mode badge.

Read the license config:
```dart
final config = await LicenseService(db).getConfig();
final expiresAt = config?.expiresAt;
final mode = config?.mode;
```

Display (only when sidebar is expanded, i.e. `!compact`):
```
[existing session mode badge]
──────────────────────────
SUBSCRIPTION
Trial · 18 days remaining   ← if mode == CLOUD_TRIAL
Active · Renews Jul 13      ← if mode == CLOUD_ACTIVE
⚠ Expiring in 3 days        ← if softLocked
```

Use a `FutureBuilder` inside `SessionModeBadge` to read the license config.
Days remaining = `expiresAt.difference(DateTime.now()).inDays`.
If `inDays < 0` show 0. If `inDays < 7` show amber text, else show white/60.

---

## MAIN SCAFFOLD CHANGES SUMMARY

After adding Features 1 through 7, the updated `_buildRoleConfig` for the
owner role needs these additions to `_pages` and `_sections`:

Add to `_pages` (owner):
```dart
ClimateScreen(),            // after HousesScreen
EggAnalyticsScreen(),       // after EggProductionScreen  ← accessible via nav push only
FeedAnalyticsScreen(),      // accessible via nav push only
SalesAnalyticsScreen(),     // accessible via nav push only
ComprehensiveReportScreen(),// replaces ReportLogScreen
```

Note: Analytics screens for Eggs, Feed and Sales are pushed via Navigator
from within their parent screens — they do NOT need sidebar entries.
Only `ClimateScreen` and `ComprehensiveReportScreen` get sidebar entries.

Updated `OPERATIONS` section for owner (re-number all indices after adding
Climate at index 7 — shift all subsequent indices up by 1):
```dart
SidebarMenuItem(index: 7, icon: Icons.thermostat_rounded, label: 'Climate'),
// then Quarantine moves to index 8, Sales to 9, etc.
```

Updated `GOVERNANCE` section — replace `ReportLogScreen` entry with
`ComprehensiveReportScreen` (same label "Reports & Logs", same index position).

---

## CHECKLIST

- [ ] `ClimateScreen` created and added to owner sidebar
- [ ] `ComprehensiveReportScreen` created with two tabs (Farm Report + logs)
- [ ] `EggAnalyticsScreen` created and reachable from `EggProductionScreen`
- [ ] `FeedAnalyticsScreen` created and reachable from `FeedManagementScreen`
- [ ] `SalesAnalyticsScreen` created and reachable from `SalesScreen`
- [ ] `CustomerStatementScreen` created and reachable from `CustomerDirectoryScreen`
- [ ] `SupplierStatementScreen` created and reachable from `SupplierDirectoryScreen`
- [ ] `SessionModeBadge` shows subscription tier and days remaining
- [ ] All new screens read from local SQLite only (no Supabase calls)
- [ ] All new screens follow existing dark-card visual language
- [ ] `main_scaffold.dart` `_pages` and `_sections` indices are contiguous
      (no gaps, no duplicates) after all additions
- [ ] `flutter analyze` has no new errors
