# App Store Connect – iOS App Review & Production Requirements

This document summarizes Apple’s requirements for **first-time review**, **TestFlight**, and **production** distribution. Use it as a checklist for YetiMatch (and other iOS apps).  
**Source:** [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (review periodically for updates).

---

## Before You Submit (Checklist)

- [ ] **Test for crashes and bugs** – Run on real devices; fix all critical issues.
- [ ] **Complete and accurate metadata** – App name, description, screenshots, previews, keywords, subtitle. No placeholder text.
- [ ] **Contact information** – Update so App Review can reach you; include Support URL in app and in App Store Connect.
- [ ] **Full access for App Review** – If the app has login/account features:
  - Provide an **active demo account** (username/password) in App Review Information, **or**
  - A **fully-featured demo mode** (with prior Apple approval if you cannot provide a demo account).
  - Backend and any required hardware (e.g. QR codes) must be **live and accessible** during review.
- [ ] **Non-obvious features and IAP** – Describe in **Notes for Review** with enough detail; include documentation if needed.
- [ ] **Human Interface Guidelines** – Follow [HIG](https://developer.apple.com/design/human-interface-guidelines/).
- [ ] **Other docs** – Align with [App Store Connect Help](https://developer.apple.com/help/app-store-connect/), [Developer Account Help](https://developer.apple.com/help/account/), and any relevant API docs.

---

## 1. Safety

- **1.1 Objectionable content** – No defamatory, discriminatory, violent, pornographic, or misleading content (e.g. fake trackers, prank calls). No profiting from tragedies.
- **1.2 User-generated content** – If present: filtering, reporting, blocking abusive users, and published contact info required.
- **1.3 Kids Category** – Stricter rules: no links/purchases outside a parental gate; comply with children’s privacy laws; limited third-party analytics/ads.
- **1.4 Physical harm** – No apps that risk physical harm (e.g. inaccurate medical/health data, encouraging dangerous behavior).
- **1.5 Developer information** – Valid, easy-to-find contact info in app and Support URL.
- **1.6 Data security** – Handle user data securely; prevent unauthorized access/disclosure (see also Guideline 5.1).

---

## 2. Performance

### 2.1 App Completeness (very common rejection)

- **Final build** – No placeholders, empty sites, or temporary content. All URLs and metadata must be real and working.
- **Test on device** – No crashes or obvious technical problems.
- **Login/demo** – If the app has login:
  - Provide **demo account** credentials in App Review Information, **or**
  - An approved **built-in demo mode** that shows full features.
- **Backend** – Services must be **on and reachable** during review.
- **IAP** – All in-app purchases must be complete, visible to the reviewer, and functional; explain in notes if something cannot be reviewed.

### 2.2 Beta testing

- Use **TestFlight** for betas/trials; don’t ship beta or trial builds as the main App Store binary.
- TestFlight builds should still comply with the App Review Guidelines.

### 2.3 Accurate metadata

- **Privacy** – Privacy info and labels must match app behavior.
- **Description, screenshots, previews** – Must reflect the real app experience; keep them updated with each version.
- **No hidden features** – All features must be documented in Notes for Review and be reviewable.
- **IAP** – Description/screenshots must state when content or features require additional purchase.
- **Screenshots** – Show the app in use (not only title art, login, or splash).
- **Previews** – Only real app screen captures; narration/overlays allowed to explain.
- **Category** – Choose the correct category; answer age-rating questions honestly.
- **Name/keywords** – Unique name (≤30 characters); no trademark stuffing or irrelevant pricing in metadata.
- **Metadata age** – Icons, screenshots, previews must be suitable for 4+ even if the app is rated higher.
- **Rights** – You must have rights to all materials in icons, screenshots, previews; use fictional account data, not real users.
- **Platform focus** – Don’t promote other platforms or alternative app stores in app or metadata unless explicitly allowed.
- **What’s New** – Clearly describe new features and significant changes.

### 2.4 Hardware compatibility

- iPhone apps should run on iPad where possible.
- No excessive battery drain, heat, or strain; no unrelated background processes (e.g. crypto mining).
- Don’t ask users to restart the device or change unrelated system settings.

### 2.5 Software requirements

- Use **public APIs** only; support the **current shipping OS**; phase out deprecated APIs.
- App must be **self-contained**; no downloading/executing code that changes app behavior (except in narrow cases, e.g. educational code).
- No malware, abuse of Push/Game Center, or harm to the system.
- **IPv6** – App must work on IPv6-only networks.
- In-app browsers must use **WebKit** (or an approved alternative engine entitlement).
- **Recording/usage** – Explicit consent and clear indication when recording, logging, or capturing user activity (camera, mic, etc.).
- **Ads** – Only in the main app binary; appropriate for age rating; clear close/skip for interstitials; no targeting based on sensitive data (e.g. health, kids).

---

## 3. Business

### 3.1 Payments

- **Digital goods/features inside the app** – Use **In-App Purchase** (e.g. subscriptions, unlocks, premium content). No external purchase links for digital content except where an entitlement applies (e.g. Reader apps, certain storefronts).
- **Subscriptions** – Must provide ongoing value; minimum period and cross-device rules apply; clear description before purchase; no bait-and-switch.
- **Restore** – Provide a way to **restore** restorable IAP.
- **Loot boxes / random items** – Disclose **odds** before purchase.
- **Physical goods / services outside the app** – Use payment methods other than IAP (e.g. Apple Pay, card).

### 3.2 Other

- No fake reviews, chart manipulation, or paid/incentivized review schemes.
- No forcing users to rate, review, or download other apps to access functionality.

---

## 4. Design

- **4.1 Copycats** – Original idea and execution; no impersonation of other apps or misuse of others’ branding.
- **4.2 Minimum functionality** – App must offer clear utility or lasting value; not just a repackaged website, ad, or link collection. Must work without requiring another app.
- **4.3 Spam** – No duplicate Bundle IDs for the same app; no category stuffing.
- **4.8 Sign-in** – If you use **third-party or social login** (e.g. Facebook, Google) for the **primary** account, you must also offer **Sign in with Apple** (or another option that meets the same privacy/consent criteria). **Exception:** Your own company account system only (e.g. email/password only) does not require Apple Sign-In.

---

## 5. Legal

### 5.1 Privacy

- **Privacy policy** – **Required.** Link in App Store Connect metadata **and** inside the app, easy to find. Policy must:
  - Say what data is collected, how, and for what use.
  - Name third parties that get user data and state they provide equivalent protection.
  - Describe retention/deletion and how users can revoke consent or request deletion.
- **Consent** – Get user consent for collecting user/usage data; don’t tie paid functionality to granting unnecessary permissions.
- **Data minimization** – Request only data needed for the feature.
- **Account deletion** – If you offer account creation, you must **offer account deletion inside the app** ([guidance](https://developer.apple.com/support/offering-account-deletion-in-your-app/)).
- **Optional login** – If the app doesn’t need an account for core features, allow use without sign-in.
- **Kids** – Comply with COPPA, GDPR, and other children’s privacy laws; extra limits on analytics and ads in Kids Category.

### 5.2 Intellectual property

- Only use content you own or have rights to; no misleading or copycat names/metadata.

### 5.3–5.6

- **Gambling/gaming** – Only with proper licensing and geo-restriction where required.
- **VPN / MDM** – Specific technical and policy requirements; declare data use.
- **Developer Code of Conduct** – Honest representation, no harassment, no review manipulation, no discovery fraud. Use the **standard API** for in-app review prompts (no custom review prompts).

---

## TestFlight vs Production

| Aspect | TestFlight | Production (App Store) |
|--------|------------|-------------------------|
| **Purpose** | Internal/external testing | Public distribution |
| **Guidelines** | Should comply with App Review Guidelines | Must comply fully |
| **Build** | Same binary intended for public release | Final version with complete metadata |
| **Demo account** | Often needed if app has login | Required if app has login (or approved demo mode) |
| **Metadata** | Basic | Complete (screenshots, description, privacy, etc.) |

- Use TestFlight to validate builds and flows **before** submitting for App Review.
- Production submission requires all “Before You Submit” and section 1–5 requirements to be met.

---

## Technical / Submission

- **SDK** – Use the current or required SDK (e.g. Apple has announced iOS 26 SDK requirement for uploads from April 2026; check [submission page](https://developer.apple.com/app-store/submitting/) for current minimum).
- **Build** – Upload via Xcode or `altool`; select the build in App Store Connect.
- **Product page** – App name, icon, description, screenshots, previews, keywords, subtitle, age rating, optional IAP promotion.
- **Review time** – Most submissions reviewed in &lt;24 hours; complex or new issues may take longer.

---

## YetiMatch-Specific Checklist

- [x] **Login** – Email/password only → no Sign in with Apple required. If you add Google/Facebook later, add Apple as well.
- [ ] **Demo account** – Create a test account; add credentials in App Store Connect → App Review Information so reviewers can test after the 5-quiz gate.
- [x] **Privacy policy** – Link in app: menu → “Privacy policy” opens `AppConfig.PRIVACY_POLICY_URL`. Publish a real policy and set URL in `AppConfig.kt`; also add link in App Store Connect metadata.
- [x] **Account deletion** – Menu → “Delete account” (when signed in) with confirmation dialog. Deletes Firebase Auth user and clears local quiz count. When you add cloud user data (e.g. Firestore), delete that in `deleteAccount()` actuals too.
- [x] **Support/contact** – Menu → “Support” opens `AppConfig.SUPPORT_URL`. Set real URL in `AppConfig.kt`; keep contact info and Support URL up to date in App Store Connect.
- [ ] **IAP** – When you add Basic/Premium, ensure IAP is complete, restorable, and described in metadata and Notes for Review.
- [ ] **Ads** – If you show ads in the free tier, follow ad placement rules (e.g. no during quiz; clear dismiss for interstitials); metadata age rating must account for ads.

---

*Last summarized from Apple’s App Review Guidelines. Check [developer.apple.com/app-store/review/guidelines](https://developer.apple.com/app-store/review/guidelines/) for the full, current text.*
