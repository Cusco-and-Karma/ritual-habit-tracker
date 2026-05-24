#!/bin/bash
# Run this from Terminal to clean stale locks and push the nutrition changes.
cd "/Users/Barmey/Desktop/My Apps/Ritual Habit Tracker App"

# Remove stale lock files left by a crashed git process
rm -f .git/index.lock .git/HEAD.lock .git/objects/maintenance.lock

# Stage and commit
git add index.html
git commit -m "feat: nutrition - day-by-day scroll, downloadable grocery list, AI preferences panel

- Replace weekly meal accordion with horizontal day-tab selector (Mon-Sun).
  Active day is highlighted; today tab has an accent border. Clicking a tab
  swaps the meal panel in-place without a full page re-render.

- Add Download button to the generated shopping list. Exports a clean
  plain-text grocery list (categorised, with quantities and notes) as a
  dated .txt file.

- Add Nutrition Preferences panel at the top of the Nutrition tab (visible
  even before a plan exists). Includes:
    - Dietary restriction pills (Vegan, Vegetarian, Gluten-free, Dairy-free,
      Nut allergy, Halal, Kosher, Low-carb, Keto, Paleo, Low-FODMAP)
    - Eating pattern selector (Standard / Intermittent Fasting)
    - IF window selector (14:10, 16:8, 18:6, 20:4, OMAD)
    - Free-text additional nutrition goals
  All preferences are passed as hard constraints to the AI when generating
  or regenerating a plan."

# Push
git push origin main

echo ""
echo "Done - changes pushed to GitHub."
