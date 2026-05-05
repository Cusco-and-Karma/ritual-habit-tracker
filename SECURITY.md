# Pre-publish security checklist

This is a static, single-file web app (`index.html`) that talks to Firebase
Auth + Firestore and (optionally) the Anthropic API directly from the browser.
Before you push to GitHub or deploy to Netlify, walk through this checklist.

---

## 1. Repo hygiene (before `git init`/`git push`)

- [ ] Confirm `.gitignore` is in place. It excludes `.DS_Store`, env files,
      private keys, and the old draft HTML files
      (`habit-tracker*.html`, `Ritual-Habit-Tracker.html`, etc.).
- [ ] Run `git status` and verify only `index.html`, `_headers`,
      `netlify.toml`, `firestore.rules`, `SECURITY.md`, and `.gitignore`
      are staged. Old drafts should be ignored.
- [ ] You can keep the old drafts on disk for reference — they just won't be
      pushed. If you don't want them around at all, delete them.
- [ ] Make the GitHub repo **public only after** you've confirmed there are
      no secrets in the diff. The Firebase web config is *not* a secret
      (see §2), but anything else (`.env`, service account JSON) is.

## 2. Firebase web config — what's actually exposed

The block in `index.html` around `firebaseConfig = { apiKey: ... }` looks
like a secret but isn't. Google designs these values to be public; they
identify your project, not authenticate it. **Real access control comes
from Firestore Security Rules and Firebase App Check.** Do these:

- [ ] **Deploy `firestore.rules`** (provided in this repo):
      `firebase deploy --only firestore:rules`
      This locks `users/{uid}` so only the owning user can read/write,
      and denies everything else.
- [ ] **Restrict the API key** in the Google Cloud Console
      (APIs & Services → Credentials → your Browser key):
      - Application restrictions → HTTP referrers
      - Allow only your Netlify domain(s) and `localhost` for dev
- [ ] **Enable Firebase App Check** (reCAPTCHA Enterprise or v3 provider).
      This stops attackers from hitting Firebase from non-browser clients
      that bypass the API-key referrer check.
- [ ] **Lock down Firebase Auth methods**: Auth → Sign-in method.
      Disable any provider you don't use. You're using email/password.
- [ ] **Set authorized domains** in Auth → Settings → Authorized domains
      to your Netlify domain (and `localhost` for dev).

## 3. Anthropic API key — current model and risks

Right now each user pastes their own `sk-ant-...` key into a settings field;
it's stored in `localStorage` and sent directly to `api.anthropic.com` from
the browser (with the header `anthropic-dangerous-direct-browser-access:true`).

This means:
- Each user must own a paid Anthropic account.
- Any successful XSS on your domain can read the key from `localStorage`.
- The key is per-device (localStorage isn't synced).

If you're publishing publicly, **strongly consider** moving the AI call to a
serverless function so users don't need their own key:

- [ ] Create a Netlify Function (`netlify/functions/ai.js`) that holds your
      Anthropic key in a Netlify environment variable and proxies the call.
- [ ] Add rate-limiting (per-IP or per-Firebase-uid) so the function can't
      drain your account.
- [ ] Replace the in-page `fetch('https://api.anthropic.com/v1/messages', …)`
      call (currently around line 2400 of `index.html`) with a call to
      `/.netlify/functions/ai`.
- [ ] Remove the API-key input UI and the `localStorage.getItem('ritualApiKey')`
      logic.

If you keep the bring-your-own-key model, at least:
- [ ] Add a clear warning in the API-key settings UI that the key is stored
      locally and could be exposed to any script with XSS access.

## 4. XSS hardening (already applied)

The following defenses are already in `index.html`:

- An `escapeHtml(s)` helper escapes `& < > " '` before any user-controlled
  string is interpolated into `innerHTML`.
- All habit names, times, subcategory labels, rating labels, daily
  reflections, and emoji values pass through `escapeHtml` (or `emojiHTML`,
  which now escapes internally).
- A Content-Security-Policy `<meta>` tag in the document head and the
  `_headers` file restrict which origins can serve scripts/styles/fetch
  destinations. Anthropic, Firebase, and Google Fonts are allowlisted.

If you ever add new `innerHTML` writes that include user data, route the
data through `escapeHtml` first.

## 5. Netlify deploy

- [ ] Connect the GitHub repo in the Netlify dashboard. Build command: leave
      blank. Publish directory: `.` (matches `netlify.toml`).
- [ ] First deploy: confirm `_headers` is being served. Open DevTools →
      Network → click the document request → check that
      `Content-Security-Policy`, `Strict-Transport-Security`,
      `X-Frame-Options: DENY`, etc. are present.
- [ ] Visit your site once and use it normally. Watch the DevTools console
      for CSP violations. If a legitimate request is blocked, add its
      origin to the `connect-src` / `script-src` / etc. directive in
      *both* `_headers` and the inline `<meta http-equiv>` in `index.html`.
- [ ] Optional: enable Netlify's **HTTPS Strict Transport Security** and
      **Asset optimization** in Site settings.

## 6. Account-takeover surface (Firebase Auth)

- [ ] Email enumeration: Firebase's default error messages reveal whether
      an email is registered. Consider enabling
      "Email enumeration protection" in Firebase Auth → Settings.
- [ ] Password policy: in Firebase Auth → Settings → Password policy, set
      a minimum length of at least 8 characters (the app currently shows a
      hint of "min 6 characters" — bump that too if you raise the minimum).
- [ ] Email verification: consider requiring verified emails before
      allowing Firestore sync.

## 7. Things this checklist intentionally does not cover

- **Backups of user data.** Firestore has built-in backups; configure them
  in the Firebase console if you care about durability.
- **GDPR / privacy policy / terms of service.** If you collect data from
  users in the EU/UK, you need a privacy policy. Not a security issue
  per se, but required before public launch.
- **Logging / monitoring.** Static site, no server logs. If you add a
  function, add structured logging there.
