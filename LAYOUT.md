Wireframe Layout for Multi-Feature Astrology App (iOS & Android)

We designed a modern, user-friendly astrology app by studying leading apps (AstroSage, Drik Panchang, Vedic Rishi, AstroTalk) and current UX trends
play.google.com
play.google.com
. The UI emphasizes simplicity and consistency: minimal clutter, clear labels, and progressive disclosure of details
thedroidsonroids.com
thedroidsonroids.com
. We use soft, rounded containers and intuitive iconography in line with 2025 design trends
fuselabcreative.com
fuselabcreative.com
. Every screen is optimized for mobile (large touch targets, bottom navigation for thumbs
thedroidsonroids.com
, accessible font sizes
thedroidsonroids.com
). Below, each main flow is described with an ASCII mockup and key UX notes.

Onboarding & Sign-In

To onboard users quickly, the app offers social/email login with minimal steps. We use a clear welcome message and large buttons, avoiding unnecessary fields
thedroidsonroids.com
. Labels and input fields are explicit (e.g. “Email” rather than placeholder-only) and date/time fields use pickers to prevent typing errors
thedroidsonroids.com
.

Goals: Fast login (Google/Facebook or phone/email), option to skip or guest mode.

UX notes: Large touch buttons (≥44pt/48dp) and thumb-friendly placement
thedroidsonroids.com
thedroidsonroids.com
.

+---------------------------------+
|  ♓ AstrologyApp (logo)          |
+---------------------------------+
| Welcome! Please sign in         |
| or create an account to begin.  |
|                                 |
| [Continue with Google]          |
| [Continue with Facebook]        |
| [Sign in with Email or Phone]   |
+---------------------------------+
|   [ Guest mode ] [ Sign Up ]    |
+---------------------------------+


Above, each button spans the width (easy tap
thedroidsonroids.com
).

A “Guest mode” link provides limited access (for exploration).

We use clear labels and avoid forcing text entry where possible (e.g. an Email field and “Continue” button).

Home Screen

The Home dashboard summarizes key features. A top bar shows the app name/logo on the left and a profile/notification icon on the right. A personalized greeting (“Hi, [Name]!”) and today’s date appear prominently. Below are quick-access cards or icons for common tasks (today’s horoscope, Kundli, Panchang, astrologer chat, etc.). We use a bottom tab bar with 4–5 tabs (Home, Panchang, Kundli, Chat, Profile) for primary navigation
thedroidsonroids.com
thedroidsonroids.com
, which is a thumb-friendly, industry-standard pattern.

Design: Soft cards and icons, consistent color palette, legible fonts
fuselabcreative.com
thedroidsonroids.com
. Buttons and icons have descriptive text and are spaced for one-handed use
thedroidsonroids.com
thedroidsonroids.com
.

Contents: Daily horoscope preview, links to generate/view Kundli, upcoming festivals/muhurats, and live astrologer options.

+---------------------------------------------------+
| ☰   AstrologyApp                        🔔   👤  |
+---------------------------------------------------+
| Hi, [User]!  Today is Jul 15, 2025               |
| Your Sign: ♌ Leo      [ View Horoscope ▶ ]       |
|                                                   |
|  [Daily Horoscope]   [Generate Kundli]           |
|  [Panchang Today]    [Talk to Astrologer]        |
+---------------------------------------------------+
| Home | Panchang | Kundli | Chat  | Profile        |
+---------------------------------------------------+


Top nav includes a hamburger menu (for secondary options) and notification bell.

The greeting and date make it friendly; a “View Horoscope” call-to-action is prominent.

Cards for each feature use concise labels.

The bottom navigation bar (tabs) is always visible for quick switching
thedroidsonroids.com
.

Panchang (Calendar) Screens

Monthly Calendar: Users can view a traditional Hindu calendar grid with each day labeled by date, weekday, and key panchang elements or festival icons
apps.apple.com
apps.apple.com
. A simple toolbar lets users switch month and access search or menu.

Features: Lunar/solar toggle, festival highlights, location-based Panchang data.

UX notes: Use bold today’s date; tapping a day opens details; spacing ensures easy tap targets
thedroidsonroids.com
.

+---------------------------------------------+
|  [◀]    July 2025      [▶]   [🔍]  [☰]     |
+---------------------------------------------+
| Su Mo Tu We Th Fr Sa                        |
|     1*  2   3   4   5   6   7★            |
|  8   9  10  11  12  13  14               |
| 15  16  17  18  19  20  21               |
| 22  23  24  25  26  27  28               |
| 29  30  31*                              |
+---------------------------------------------+
| * = Festival  ★ = Holiday                   |
| Tap a date to see full Panchang details.    |
+---------------------------------------------+


Festivals or holidays are marked with symbols.

Above, * marks festivals (e.g. Ekadashi); ★ marks holidays.

The footer instructions guide the user to tap a date.

Daily Detail (Panchang): Tapping a date shows its panchang details (tithi, nakshatra, yoga, karana, vara), plus special timings (e.g. Abhijit Muhurta, Rahu Kaal) and festival notes
apps.apple.com
apps.apple.com
.

+-----------------------------------+
| Jul 7, 2025                    ←  |
+-----------------------------------+
| Tithi: Ashtami (8th)               |
| Nakshatra: Mṛgaśīrṣa              |
| Yoga: Siddhi  |  Karana: Bāva     |
| Day: Thursday                     |
| Festival: Guru Purnima            |
| Choghadiya: Day [Peet (1hr 13m)]  |
| Rahu Kaal: 12:21 – 13:54          |
+-----------------------------------+
| [ Back ] [Save to Calendar] [Share]|
+-----------------------------------+


Important details are grouped: panchang elements at top, special times below.

We show a festival name if it falls on that day.

Action buttons allow saving or sharing the date.

Kundli & Horoscope Screens

Kundli Input: Users enter their birth details to generate a birth chart. We use clearly labeled fields with pickers for date and time
thedroidsonroids.com
 to reduce typing errors, and a location search box. Options like chart style (North/South) and language are available.

+---------------------------------------+
|         Generate Your Kundali         |
+---------------------------------------+
| Name: [__________]                    |
| DOB: [ 14 / Aug / 1990 ▾] ⏰ [ 07:30 ▾]|
| Gender: [♂ Male ▾]    Time Zone: [IST]|
| Birth Place: [ Mumbai, India 🔍 ]     |
| Language: [Hindi ▾]  Chart: [North ▾] |
+---------------------------------------+
|           [ Generate Kundali ]        |
+---------------------------------------+


Dropdowns (▾) use native pickers (calendar and clock).

We adhere to platform form guidelines (large inputs and buttons
thedroidsonroids.com
, logical grouping
thedroidsonroids.com
).

The Generate button is prominent and enabled only when fields are valid (progressive disclosure).

Kundli Chart Display: After generation, the app shows the birth chart. We support both North and South Indian chart styles
apps.apple.com
, with planetary positions listed. Text and table layouts are used for clarity.

+--------------------------------------+
|           Kundali: John Doe         |
+--------------------------------------+
|       [ Chart Image (North) ]        |
|                                      |
| Planets:                             |
| Sun   – Sagittarius 10°45'          |
| Moon  – Aries  5°12'               |
| Mars  – Virgo  23°08'              |
| ... (others)                        |
+--------------------------------------+
|  [ Download PDF ]  [ Save Chart ]    |
+--------------------------------------+


The chart is centered, with planets listed below for easy reading.

Buttons like “Download PDF” and “Save” are placed for quick action.

This follows DrikPanchang’s feature of saving or printing kundli
apps.apple.com
.

Horoscope (Rashifal): The app provides daily, weekly, monthly, and yearly horoscopes by zodiac sign
play.google.com
play.google.com
. The interface shows a summary and lets users switch timeframes.

+---------------------------------------+
|          Daily Horoscope             |
+---------------------------------------+
| Your Sign: ♍ Virgo                    |
| "Today encourages you to start anew…"  |
| (brief snippet of prediction)         |
+---------------------------------------+
| [Read More ▶]  [Weekly]  [Monthly]   |
+---------------------------------------+


The main horoscope line is highlighted; tapping “Read More” expands the full text.

Tabs or buttons switch between Daily/Weekly/Monthly views, reflecting AstroSage’s multiple horoscope offerings
play.google.com
.

Chat & Astrologer Consultation

We integrate chat and call flows for speaking with astrologers, inspired by AstroTalk. The user selects an astrologer from a list or joins live sessions. Calls use a wallet-based payment (AstroTalk: “Recharge wallet and start a call”
play.google.com
).

 

Astrologer List: Shows available experts with rating, fee, and chat/call buttons.

+--------------------------------------+
|   Astrologers Available Now         |
+--------------------------------------+
| 🙍‍♂️  Pandit Sharma   ★4.9          |
|      Price: ₹10/min   [Chat][Call]   |
| 🙎‍♀️  Sangeeta Ji     ★4.7          |
|      Price: ₹8/min    [Chat][Call]   |
| ... more astrologers ...            |
+--------------------------------------+


Each entry has the astrologer’s avatar, name, rating, fee, and two action buttons.

[Chat] opens text chat; [Call] initiates a voice call (after confirming payment)
play.google.com
.

Chat Screen: The chat UI resembles a typical messenger for usability.

+--------------------------------------+
| 🌟 Sangeeta Ji (Astrologer)          X |
+--------------------------------------+
| You: Hi, I have a question about my career... |
| Astrologer: Hello, please tell me more.        |
|  ... chat history ...                           |
+--------------------------------------+
| [Type your message here...]       [Send ▶]      |
+--------------------------------------+


Messages are shown in speech bubbles; timestamps can appear.

The input box stays above the keyboard.

Emoji or quick actions (attach birth chart) could be added.

Live Call Screen: For a voice/video call, we include in-call controls.

+--------------------------------------+
|    [🎥]    [🔇]    [🔊]     [End]     |
+--------------------------------------+
| *(Live voice conversation)*          |
|                                        |
+--------------------------------------+


Controls: toggle video, mute mic, speaker, and end call.

This respects thumb-friendly placement (bottom center)
thedroidsonroids.com
.

Wallet/Payments: A simple wallet screen lets users add funds or view balance, necessary for paid calls.

+-----------------------------------+
|       Wallet Balance: ₹125        |
+-----------------------------------+
| [ Add Money ]  [Transaction History] |
+-----------------------------------+


“Add Money” opens payment options; transactions show call charges.

We highlight subscription deals (e.g. AstroSage’s free first chat) as promos.

Profile & Settings

The Profile screen shows account info and app preferences:

+-------------------------------------+
| [Avatar]   Jane Doe                 |
+-------------------------------------+
| Email: jane@example.com             |
| Language: English [Change ▾]        |
| Chart Style: North Indian [Change ▾]|
| Timezone: IST (+5:30)               |
+-------------------------------------+
| [ Edit Profile ]  [ Logout ]        |
+-------------------------------------+
|        *Premium Subscription*       |
| - Remove Ads (Active)               |
| - Offer: Horoscope Report ₹199/yr   |
+-------------------------------------+


Users can edit their name, change language (English/Hindi/Telugu etc.
play.google.com
), and switch chart style.

The subscription section (e.g. ad-removal) is modeled on DrikPanchang’s in-app purchase offerings
apps.apple.com
.

Additional Modules (Optional)

Based on the referenced apps, we may include extras like Baby Name by Nakshatra or AstroMall (remedies shop). These follow the same UI style:

+------------------------------------+
| Baby Name by Nakshatra            ✏️ |
+------------------------------------+
| Child Gender: [♀ Girl ▾]           |
| Nakshatra of Birth: [Rohini ▾]     |
+------------------------------------+
| [ Generate Name Suggestions ]      |
+------------------------------------+

+----------------------------------+
|     AstroMall - Remedies        🛒 |
+----------------------------------+
| [💎 Ruby]  Red Gemstone – ₹500   |
| [🔮 Puja Kit] Prosperity Pack – ₹999  |
+----------------------------------+


These screens keep the same clean layout and large buttons, consistent with overall design.

Navigation & UX Best Practices

Throughout the app we follow proven mobile design principles
thedroidsonroids.com
thedroidsonroids.com
:

Layout & Navigation: A bottom tab bar (Home, Panchang, Kundli, Chat, Profile) makes primary functions instantly reachable
thedroidsonroids.com
. We avoid hidden menus; secondary features (settings, help) are in top/hamburger menus.

Readability: We use platform minimum font sizes (≥11pt iOS, 12sp Android) to ensure text is legible
thedroidsonroids.com
. All touch targets (buttons, tabs) meet the 44x44pt (iOS) or 48x48dp (Android) guideline to prevent mistaps
thedroidsonroids.com
.

Accessibility: Dark mode support and adjustable text (dynamic fonts) are included per OS settings. Color contrast meets WCAG standards for readability.

Consistency: Colors, icons, and typography are uniform app-wide
thedroidsonroids.com
, so users build a strong mental model. Interactions follow native patterns (e.g. iOS back-swipe, Android back-button).

Micro-interactions: Subtle animations (button press feedback, loading spinners) provide responsive feedback and delight
fuselabcreative.com
thedroidsonroids.com
. For example, a loading indicator appears when generating a Kundli, improving perceived performance.

Form Design: We minimize form fields and use smart defaults. Date pickers and location autocomplete reduce typing
thedroidsonroids.com
. Inline validation shows errors immediately (e.g. “Invalid time”).

Progressive Disclosure: Complex details (full kundli interpretation, extensive Panchang info) are hidden behind “Read More” or tabs, so users aren’t overwhelmed
thedroidsonroids.com
.

By combining these principles with the feature sets of the reference apps (free horoscope, kundli matching, chat with astrologers, etc.
play.google.com
play.google.com
), the ASCII layouts above present a modern, comprehensive astrology app design. Each screen is crafted for ease of use on both iOS and Android, ensuring users can perform any operation (view calendars, generate charts, or consult experts) with a few intuitive taps.

 

Sources: Design guidelines and features are informed by our research into top astrology apps and UI best practices
fuselabcreative.com
play.google.com
apps.apple.com
play.google.com
thedroidsonroids.com
.