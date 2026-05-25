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
git commit -m "feat: boxing weeks 6&11 only, phase exercise/meal variation, nutrition date scroller to top, grocery .docx export

- Boxing appears exclusively on weeks 6 and 11 via week_overrides — fully replaces that day's workout; no boxing shown on any other week
- Training AI prompt requires phase_schedules: completely different exercises per phase (hypertrophy -> strength -> functional), rotating movements and rep ranges week to week
- getScheduleForWeek() picks the right exercise set based on phase boundaries; getWeekOverride() applies boxing/sport-specific day replacements
- Nutrition AI prompt requires meal_rotations: phase-based meal plans so food genuinely varies across the program (Mediterranean -> Asian -> Mexican)
- getMealsForDow() picks the correct meal rotation for the current training week using phase boundaries; falls back to single weekly_meals for existing plans
- Nutrition tab date scroller (day nav + meal cards) moved to top of view, above macro bars and food log — matches training tab layout
- Grocery list download now generates a proper .docx Word document via pure-JS ZIP + OOXML (no external dependencies), with heading, date, and categorised sections"

echo ""
# Push to GitHub
git push origin main

echo ""
echo "Done — changes committed and pushed to GitHub."
