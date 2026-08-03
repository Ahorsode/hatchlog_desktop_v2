# Agent Prompt — Desktop Dashboard Redesign (pfm-desktop)

## What You Are Redesigning

`lib/screens/overview.dart` — the main dashboard screen shown to all roles.

The current dashboard has 4 basic stat cards, a batch grid, and a recent
activity panel. The redesign makes it a high-density, data-rich command centre
that gives an owner or operator a full picture of farm health in one glance —
no navigation needed for the key numbers.

All data is from local SQLite Drift streams. No Supabase calls in this file.
The visual language stays consistent with the rest of the app:
dark cards, `cs.primary` accents, `cs.onSurface` text, `cs.outline` borders,
`BorderRadius.circular(24)`, subtle box shadows.

---

## Delete the Entire Current `overview.dart` Content

Replace everything inside `overview.dart` from scratch. Keep only the file
header imports (add `rxdart` if not already imported, add `dart:math`).

Required imports:
```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/local_db.dart';
import '../services/license_service.dart';
import '../utils/user_role.dart';
```

---

## Architecture

The screen is now role-aware. The `OverviewPage` widget receives the role
from `MainScaffold` via `UserSession` (same way other screens do it).

```dart
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: UserSession().getRole(),
      builder: (context, snapshot) {
        final role = UserRoleUtils.normalize(snapshot.data ?? '');
        if (role == UserRoleUtils.operational) {
          return const _OperationalDashboard();
        }
        return const _OwnerDashboard();
      },
    );
  }
}
```

---

## OWNER DASHBOARD — `_OwnerDashboard`

Full-width scrollable column with 5 distinct rows.

### ROW 1 — Page Header

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(40, 32, 40, 0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left: Title block
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Farm Command Centre',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
            letterSpacing: -0.8, color: cs.onSurface)),
        const SizedBox(height: 4),
        Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
      ]),
      const Spacer(),
      // Right: Sync badge + Subscription badge
      _SyncBadge(),
      const SizedBox(width: 12),
      _SubscriptionBadge(),
    ],
  ),
)
```

**`_SubscriptionBadge` widget:**
Reads `LicenseService(db).getConfig()` via FutureBuilder.
Shows: "Trial · N days" (amber) or "Active · renews DATE" (green) or
"⚠ Expiring" (red).
Same pill shape as the existing sync badge.

---

### ROW 2 — KPI Cards Strip

Six stat cards in a `Wrap` with spacing 20. Cards are fixed width calculated
to show 6 across on wide screens (>1400px), 3 on medium (>900px), 2 on narrow.

Each card uses `_KpiCard` widget:
```dart
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;      // e.g. "vs yesterday ↑ 12%"
  final IconData icon;
  final Color color;
  final double parentWidth;
  const _KpiCard({...});
}
```

Card visual (same style as current stat cards but with subLabel line added):
```
[ icon circle ]
[ value — large bold ]
[ label ]
[ subLabel — small, grey or green/red depending on trend direction ]
```

**The 6 KPI Cards and their data sources:**

**Card 1 — Total Live Birds**
- Value: sum of `batches.current_count` where `status == 'active'`
- SubLabel: "across N active batches"
- Icon: `Icons.pets_rounded` | Color: `Colors.orange`

**Card 2 — Today's Eggs**
- Value: sum of `egg_productions.eggs_collected` where `log_date == today`
- SubLabel: Compare with yesterday. If today > yesterday show "↑ N vs yesterday"
  in green. If today < yesterday show "↓ N vs yesterday" in red. If equal
  show "Same as yesterday" in grey.
- Icon: `Icons.egg_rounded` | Color: `Colors.amber`
- Stream: filter `eggProductions` by `logDate` using `.where((e) => e.logDate.isBetweenValues(todayStart, todayEnd))`

**Card 3 — Revenue This Month**
- Value: sum of `sales.total_amount` where `sale_date` is in current calendar month
- Format as GHS currency: `NumberFormat.currency(locale: 'en_GH', symbol: 'GHS ').format(value)`
- SubLabel: "N sales this month"
- Icon: `Icons.trending_up_rounded` | Color: `Colors.green`

**Card 4 — Feed This Week**
- Value: sum of `feeding_logs.amount_consumed` where `log_date >= 7 days ago`, formatted as "X kg"
- SubLabel: "daily avg: X kg"
- Icon: `Icons.restaurant_rounded` | Color: `Colors.teal`

**Card 5 — Net Income This Month**
- Value: revenue_this_month - expenses_this_month
- Revenue: sum sales.total_amount (current month)
- Expenses: sum expenses.amount (current month, if `expenses` table exists in
  schema; if not, use `inventory` purchase costs or show "N/A")
- Color of value text: green if positive, red if negative
- SubLabel: "Revenue minus expenses"
- Icon: `Icons.account_balance_wallet_rounded` | Color: `Colors.purple`

**Card 6 — Mortality This Month**
- Value: sum of `mortalities.count` where `log_date` is in current month
- SubLabel: Calculate mortality rate: (total_mortality / total_initial_birds) * 100,
  show as "X.X% mortality rate". Color: red if rate > 5%, amber if > 2%, green if ≤ 2%.
- Icon: `Icons.warning_rounded` | Color: `Colors.red`

Use `CombineLatestStream` from `rxdart` where multiple tables feed one card.
Wrap each card in its own `StreamBuilder` — do NOT combine all 6 into one
giant stream. Each card is independently reactive.

---

### ROW 3 — Two-Column Main Content

`LayoutBuilder` with breakpoint at 1100px (stack below, side-by-side above).

**Left column (flex: 3) — Active Batches**

Section header: "Active Batches" with a count badge showing the number of
active batches, and a "View All →" `TextButton` that calls
`MainScaffold.of(context)?.setSelectedIndex(livestockIndex)`.

Batch cards in a responsive `GridView` (3 cols > 1200px, 2 cols > 800px, 1 col below).

**Enhanced `_OwnerBatchCard` widget** — replaces old `_PremiumBatchCard`:

```
┌─────────────────────────────────────┐
│ [LAYER PULLET] badge        [house] │  ← type + house name (if assigned)
│                                     │
│ Batch Name (large, bold)            │
│ Age: 42 Days                        │
│                                     │
│ Growth Progress bar ─────────── 60% │  ← visual progress bar
│ "Week 6 of 10" (or weeks to market) │
│                                     │
│ ──────────────────────────────────  │
│ 🐣 4,200 birds    🥚 1,840 today    │  ← if LAYER batch, show today's eggs
└─────────────────────────────────────┘
```

Growth progress: calculate as `ageDays / targetDays * 100`.
- Broiler target: 42 days
- Layer target: 70 days (until peak production)
- Progress bar: `LinearProgressIndicator` with `cs.primary` color, capped at 100%.

House name: join `houses` table by `batch.houseId` (if column exists in schema).
If `houseId` is null or not in schema, omit the house badge.

Today's eggs on batch card: only show for LAYER batches. Sub-query
`egg_productions` for this batch for today's date.

On card tap: navigate to `LivestockManager` screen and, if it supports deep
linking to a specific batch, pass the batch ID. If not, just navigate to
`LivestockManager`.

**Right column (flex: 2) — Alerts + Quick Summary**

**Alerts Panel:**

Section header: "Alerts" with a red badge showing count of active alerts.

Stream-driven list. Check these conditions and generate alert items:

```dart
// LOW FEED ALERT: inventory items where category=='FEED' and quantity < reorderLevel
// HIGH MORTALITY ALERT: any mortality log in last 7 days where count > 50
// QUARANTINE ALERT: any batch with status == 'quarantine'  
// EXPIRING SUBSCRIPTION: if license expiresAt < 7 days from now
```

Each alert item:
```
[🔴 icon]  Low Feed: Layer Mash is below reorder level
[🟡 icon]  High Mortality: 62 deaths logged in Batch A this week
[🟢 icon]  All systems normal (shown only when zero alerts)
```

Max 5 alerts shown. If more, show "See N more..." which navigates to the
relevant screen.

**Monthly Summary strip (below alerts):**

A compact card showing this month at a glance:

```
JUNE 2025
─────────────────────
Eggs:        24,800
Feed Used:   1,240 kg
Revenue:     GHS 8,400
Expenses:    GHS 3,100
Net:         GHS 5,300   ← green if positive
```

No charts. Plain text, clean alignment using `Row` + `Expanded`. Data from
same streams as KPI cards (scoped to current month).

---

### ROW 4 — Trend Charts Strip

Three equal-width chart cards in a `Row` (hide this row entirely on screens
< 1100px to avoid clutter):

**Chart Card 1 — Egg Production (7 days)**
**Chart Card 2 — Feed Consumption (7 days)**
**Chart Card 3 — Revenue (7 days)**

Each chart card:
```
┌─────────────────────────────────┐
│ Egg Production   7-day trend    │
│                                 │
│   ▐▌▐▐▌▌▐▐▌   (bar chart)    │
│                                 │
│ Mon Tue Wed Thu Fri Sat Sun     │
│ Total this week: 12,400         │
└─────────────────────────────────┘
```

Implement using `CustomPainter` — do NOT add fl_chart or any new package.

**`_MiniBarChartPainter` CustomPainter:**

```dart
class _MiniBarChartPainter extends CustomPainter {
  final List<double> values;   // one value per day, length == 7
  final Color barColor;
  final Color labelColor;
  final List<String> labels;   // ['Mon', 'Tue', ...]

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce(max);
    if (maxVal == 0) return;

    final barWidth = size.width / (values.length * 2);
    final chartHeight = size.height - 24; // reserve 24px for labels

    for (int i = 0; i < values.length; i++) {
      final barHeight = (values[i] / maxVal) * chartHeight;
      final x = i * (size.width / values.length) + barWidth / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartHeight - barHeight, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = barColor.withOpacity(0.85));
      
      // Day label
      final tp = TextPainter(
        text: TextSpan(text: labels[i],
          style: TextStyle(color: labelColor, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(_MiniBarChartPainter old) => old.values != values;
}
```

Wrap in `CustomPaint(painter: _MiniBarChartPainter(...), size: Size(double.infinity, 120))`.

Data for each chart: query past 7 days and group by date. Use
`db.customSelect()` raw query if groupBy is not easily expressible in Drift:

```dart
// Example for eggs:
final rows = await db.customSelect(
  'SELECT date(log_date) as day, SUM(eggs_collected) as total '
  'FROM egg_productions '
  'WHERE log_date >= ? '
  'GROUP BY date(log_date) ORDER BY day',
  variables: [Variable(sevenDaysAgo)],
).get();
```

Fill missing days with 0.

---

### ROW 5 — Bottom Row: Recent Activity + Houses Strip

Two columns (stack on screens < 1100px).

**Left column (flex: 3) — Enhanced Recent Activity**

Same concept as current `_RecentActivityPanel` but expanded to include Sales
and Expenses in the activity stream, not just feed/mortality/eggs.

Stream combines:
```dart
CombineLatestStream.list([
  db.select(db.feedingLogs).watch(),
  db.select(db.mortalities).watch(),
  db.select(db.eggProductions).watch(),
  db.select(db.sales).watch(),
  // Add expenses if table exists in schema
])
```

Sort all combined by date descending, take 12.

For `Sale` items in the activity feed:
- Icon: `Icons.receipt_long_rounded` | Color: `Colors.green`
- Title: `"Sale: GHS ${sale.totalAmount.toStringAsFixed(2)}"` (or format with currency)
- Subtitle: date

Show "View All →" button that navigates to `SalesScreen`.

**Right column (flex: 2) — Houses at a Glance**

Compact scrollable list of all houses. Each row:

```
🏠  Broiler House A     🌡 28°C  💧 55%   [OPTIMAL badge]
🏠  Layer Block 1       🌡 34°C  💧 72%   [ATTENTION badge]
🏠  Growers Pen         🌡 --    💧 --    [UNKNOWN badge]
```

Use the same climate colour logic as Feature 1 (Climate Screen).
Each row taps to navigate to `ClimateScreen` (add via `MainScaffold.of(context)?.setSelectedIndex`).

Section header: "Houses" + "Manage →" button.

Stream: `(db.select(db.houses)..where((h) => h.farmId.equals(boundFarmId))).watch()`

If no houses: show a minimal message "No houses registered."

---

## OPERATIONAL DASHBOARD — `_OperationalDashboard`

Workers and operational staff see a simpler, task-focused dashboard.

```
Header: "Today's Operations"
Subtitle: DateFormat('EEEE, d MMMM').format(DateTime.now())

Row 1 — Three stat cards (today only):
  - Eggs Collected Today
  - Feed Logged Today (kg)
  - Mortality Today

Row 2 — Two columns:
  Left: Active Batches (compact list, not grid — just batch name + bird count)
  Right: Quick Log section:
    - [+ Log Eggs] button → Navigator.push to EggProductionScreen
    - [+ Log Feed] button → Navigator.push to FeedManagementScreen
    - [+ Log Mortality] button → Navigator.push to MortalityScreen
    (All three are large pill-shaped action buttons, stacked vertically)

Row 3 — Today's Activity:
  Same as _RecentActivityPanel but filtered to today only (logDate == today)
```

All data scoped to today using `.where((e) => e.logDate.isBetweenValues(todayStart, todayEnd))`.

The operational dashboard intentionally has no financial data — workers don't
see revenue, expenses, or net income.

---

## HELPER WIDGETS TO CREATE

All defined at the bottom of `overview.dart` as private classes.

**`_SectionHeader` widget:**
```dart
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  // Renders: [icon] Title ─────────── [action button]
}
```

**`_KpiCard` widget:** (described in Row 2 above)

**`_AlertItem` widget:**
```dart
class _AlertItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onTap;
}
```

**`_MiniBarChart` widget:**
```dart
class _MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final String totalLabel; // e.g. "Total this week: 12,400"
  // Wraps CustomPaint + totalLabel text below
}
```

**`_HouseStatusRow` widget:**
For the houses-at-a-glance compact row in Row 5.

---

## WHAT NOT TO CHANGE

- Do not change `main_scaffold.dart` as part of this prompt
  (it already imports and uses `OverviewPage`)
- Do not change any other screen file
- Do not add new packages to `pubspec.yaml`
  (`rxdart`, `intl`, `url_launcher` are already present)
- Do not modify the Drift schema or any database file

---

## CHECKLIST

- [ ] `_OwnerDashboard` has all 5 rows implemented
- [ ] `_OperationalDashboard` has its simplified 3-row layout
- [ ] `OverviewPage.build()` branches on role using `UserSession().getRole()`
- [ ] All 6 KPI cards have independent StreamBuilders
- [ ] Alerts panel detects: low feed, high mortality, quarantine, expiring subscription
- [ ] Monthly summary strip shows correct month totals
- [ ] Trend charts use `CustomPainter` only (no new packages)
- [ ] Trend chart data uses `db.customSelect` grouped by date
- [ ] Enhanced batch cards show growth progress bar
- [ ] Enhanced batch cards show today's egg count for LAYER batches
- [ ] Recent activity includes Sales in the stream
- [ ] Houses strip shows temp/humidity with colour coding
- [ ] `_SubscriptionBadge` in header reads from `LicenseService`
- [ ] Operational dashboard has Quick Log buttons navigating to the right screens
- [ ] `flutter analyze` runs clean — no new errors introduced
- [ ] Screen renders without overflow on a 1280×800 window (standard laptop)
- [ ] Screen renders without overflow on a 1920×1080 window (desktop)
