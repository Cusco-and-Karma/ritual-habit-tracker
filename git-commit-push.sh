#!/bin/bash
# Run this from Terminal to commit and push the latest UI changes.
cd "/Users/Barmey/Desktop/My Apps/Ritual Habit Tracker App"

# Remove stale lock files (harmless if they don't exist)
rm -f .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock
echo "Cleared stale git lock files."

# Stage changes
git add index.html
echo "Staged index.html."

# Commit
git commit -m "feat: date-based day scroller for nutrition & training, fix meal variation, occasional activity scheduling

- Nutrition: replace Mon-Sun tab strip with date-based day scroller
  - Header shows today's actual date (e.g. 'Sun, May 24')
  - Left/right arrows to navigate previous/next day
  - Meals map to actual calendar dates via day-of-week
  - Weekly View button opens full-page overlay of all 7 days
  - Fallback to legacy single meals list removed entirely
  - Shows 'No meals planned for this day' when a day has no AI-generated meals
  - Debug log: console logs how many weekly_meals days the AI returned

- Training: date-based daily view as default
  - Header shows today's date with left/right day navigation
  - Each day shows that day's exercises, sets, reps, duration
  - Rest days shown with a recovery card
  - Weekly View button opens full-page overlay (existing weekly plan)
  - Weekly overlay supports week/phase navigation and exercise checks

- Occasional activities (swimming, boxing a few times a month)
  - AI now schedules these as specific dated entries in occasional_activities[]
  - Appear only on their specific dates in the daily view
  - Not added to weekly_schedule as recurring weekday entries

- Code cleanup
  - refreshTrainView() helper routes re-renders to overlay or main view correctly
  - CSS class conflict fixed: new plan-date-nav classes instead of date-nav"

echo ""
# Push to GitHub
git push origin main

echo ""
echo "Done — changes committed and pushed to GitHub."
