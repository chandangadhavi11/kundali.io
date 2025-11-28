Astrology App – Product Requirements Document (PRD)
Introduction & Overview

Concept illustration of an astrology app combining chat and birth chart features.
This document outlines the Product Requirements for a comprehensive Astrology & Kundli mobile application. The app will cater to users seeking Vedic astrology services such as Janam Kundli generation, daily horoscopes, Hindu calendar (Panchang) information, and personalized astrological guidance. It draws inspiration from popular apps like AstroSage Kundli, AstroTalk, and Drik Panchang, aiming to combine their best features with a unique AI-powered twist. The primary goal is to deliver an all-in-one platform for astrology enthusiasts – from casual users checking daily rashifal (horoscope) to serious users generating detailed Kundli reports. A key differentiator of our app is the integration of an AI Astrologer feature that allows users to ask questions about their horoscope/Kundli and receive instant answers. The app will support both English and Hindi at launch (with plans to add other regional languages), and will offer offline access for certain features (especially the Hindu calendar) to ensure usability even without internet connectivity. Overall, the vision is to blend traditional astrology practices with modern technology – providing accurate calculations, expert insights, and convenient access anytime, anywhere.

Objectives & Vision

Comprehensive Astrology Platform: Provide a one-stop solution for all astrology needs – including Kundli creation, personalized predictions, matchmaking, panchang, and expert consultation – in a single app. Users should not need multiple apps or websites for different astrological services.

Personalized Guidance: Leverage user’s birth data to offer highly personalized horoscope readings and life predictions. Incorporate an AI-driven conversational guide to answer user-specific questions, making the experience interactive and tailored to each user’s concerns.

User Engagement & Trust: Encourage daily engagement through features like daily horoscopes and panchang updates (increasing user retention). Build trust by ensuring accuracy in calculations and providing credible content/advice (e.g. via verified astrologer inputs or well-tested algorithms). The app should humanize the astrology experience – making users feel heard and guided, not just shown generic content
miracuves.com
.

Accessibility: Make astrology accessible to a broad audience in India. This means offering content in multiple languages (starting with English/Hindi) and supporting offline usage for key features so that users in low-connectivity areas can still benefit. The UI/UX should be simple enough for non-technical or older users who may not be tech-savvy.

Scalability & Future Growth: Create a robust architecture that can scale to millions of users (since interest in astrology apps is high and growing
miracuves.com
) and easily incorporate future features. Future expansions (like onboarding live astrologers for consultations, adding new languages, or new divination methods) should be feasible without major rework.

Monetization with Value: Implement monetization strategies (such as premium subscriptions and paid consultations) that users find valuable and worth paying for. The aim is to generate revenue without compromising the user experience for free users. For example, offer advanced AI consultations or detailed report purchases for paying users, while keeping basic horoscopes free to attract a large user base.

Target Users & Market

Primary Audience: Individuals in India interested in astrology, ranging from casual followers (who read daily sun-sign horoscopes) to serious enthusiasts (who generate Kundlis, check auspicious timings, etc.). This includes young adults (e.g. Gen-Z treating birth charts like personality quizzes
miracuves.com
) as well as older users who follow traditional panchang for rituals. The app’s content and features will cater to both modern and traditional sensibilities.

Secondary Audience: The broader diaspora or anyone interested in Vedic astrology worldwide. While initial focus is on Indian users, the inclusion of English language and possibly Western horoscope features means the app can also attract global users who have an interest in Eastern astrology or want personalized readings beyond generic Western zodiac apps.

User Personas:

Casual User: Checks daily horoscope (rashifal) for entertainment or curiosity, occasionally uses the Hindu calendar for festival dates. Might ask the AI fun questions like “How will my day go?”

Seeking Guidance: Someone going through life events (career issues, marriage prospects) who wants astrological guidance. They will generate a Kundli, read detailed predictions, and likely use the AI astrologer to ask specific questions. In future, they might consult a human astrologer via the app.

Traditional User: Follows Hindu calendar for auspicious timings, uses offline panchang, and checks compatibility for arranged marriage using Kundli matching. Likely prefers content in Hindi or their native language and values accuracy in panchang data.

Platforms: Android (primary, given India’s user base) and iOS. The app should be designed as a mobile-first experience, but a responsive web or desktop version could be considered later for a wider reach.

Market Justification: Astrology and spiritual apps have seen a surge in popularity – in 2024 they saw ~23% increase in downloads globally, with India leading the trend
miracuves.com
. Competitors like AstroSage have millions of users, which validates the demand. Our app targets this thriving market with an improved feature set (especially the AI adviser and offline support) to capture users looking for a modern yet culturally rooted astrology solution.

Key Features & Functional Requirements

Below is a comprehensive list of features the app will offer. Each feature is critical to delivering the complete astrology experience and has been informed by competitor analysis and user expectations:

1. User Registration & Profile Management

Sign-Up/Sign-In: Users can register using a mobile number (OTP verification) or email; social login (Google/Facebook) is also an option for convenience. This creates a personal account to save preferences and data. Optionally, allow “Guest” usage with limited features (e.g., one can explore daily horoscopes or the calendar without sign-in).

User Profile: After registration, the user creates their astrology profile by entering birth details – name, date of birth, time of birth, and place of birth – which are needed for Kundli generation. This profile is the default “primary Kundli” for the user. The profile also stores preferred language (e.g. Hindi or English) and other settings.

Multi-Profile Support: Users can create and save multiple Kundli profiles within their account (for family members, friends, or to compare charts). For example, a user might generate and store the horoscopes of their spouse or children. The app should support storing many such profiles (AstroSage allows thousands of horoscopes to be saved
play.google.com
play.google.com
). Each profile can be named and managed (edit/update details if needed, or delete). Profiles are synced to the cloud under the user’s account so they can be accessed from multiple devices or restored on reinstall (similar to AstroSage’s cloud sync feature
play.google.com
).

Profile Data & Privacy: Sensitive data like birth details and generated charts are private to the user. We will ensure data encryption and give users the option to delete their data. If the user engages with live astrologers in future, their identity can be kept partially anonymous (e.g., use first name or a nickname) to protect privacy
miracuves.com
.

Onboarding Tutorial: On first login (or first app launch for guest), a brief walkthrough highlights key features: e.g., “Generate your Kundli”, “Ask our AI astrologer a question”, “Check today’s panchang”, etc. This helps new users understand the app’s value quickly.

2. Kundli Generation & Birth Chart Reports

Janam Kundli Creation: The app can instantly generate a detailed birth chart (Kundli) for the user (and any saved profile) using the birth date, exact time, and location. We support both North Indian and South Indian chart styles for displaying the Kundli, as users have regional preferences
play.google.com
. The user can toggle their preferred chart format.

Planetary Calculations: The system calculates planetary positions (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu; optionally outer planets Uranus, Neptune, Pluto for completeness) at the time of birth. This is done with high precision algorithms or an integrated ephemeris. The calculated Lagna (ascendant) and planetary longitudes are used to populate the 12 houses of the Kundli. Accuracy is crucial – our algorithm will match the precision of reliable sources like NASA JPL or Swiss Ephemeris to ensure the generated Kundli is correct to the minute. (As AstroSage notes, their app performs instant calculations without needing external tables
play.google.com
, and our app will do the same.)

Kundli Display: The birth chart is presented with a clear visual – showing each house with its sign and the planets in them. Planet symbols and sign glyphs will be used for an intuitive look
miracuves.com
. Users can tap on any planet or house to see details (e.g., exact degree, nakshatra, house lord, aspects). There may be an option to rotate the chart to view any house as the first house (for certain analyses) – similar to AstroSage’s “chart rotation” feature
play.google.com
.

Detailed Report & Interpretation: Alongside the chart, the app provides a textual report explaining key elements of the Kundli. For instance, it will highlight the user’s Rashi (Moon sign), Lagna (Ascendant), Nakshatra, and the positions of major planets with basic interpretations (e.g., “You have Mars in the 10th house indicating strong career drive”). The interpretative text can be generated via a mix of expert-written content and AI. This gives users a beginner-friendly explanation of their birth chart, not just raw data
miracuves.com
miracuves.com
.

Advanced Chart Features (for power users): Include divisional charts (e.g., Navamsha chart) and other calculations for those interested. The app can compute Vimshottari Dasha periods, highlight current Mahadasha/Antardasha running for the user, and display relevant info (AstroSage provides detailed Dasha down to 5 levels
play.google.com
). We may also show information like Shadbala strength of planets, Ashtakavarga scores, etc., but these can be hidden under an “Advanced” section to not overwhelm casual users.

Save & Share: Users can download their Kundli as a PDF or image, which includes the chart and summary report (useful if they want to print it or share with an astrologer)
play.google.com
. The app should allow sharing this report via WhatsApp/email directly. Also, since profiles are saved, a user can reopen any saved chart at any time without re-entering details.

Accuracy & Verification: We will validate our Kundli generation against known correct sources (e.g., compare a few sample charts with those from AstroSage or Drik Panchang) to ensure our calculations align. The algorithm details are outlined later in this document, but we will use standard Panchang formulas to compute tithi, yoga, etc., within the Kundli as well. Users should feel confident that the generated Kundli is authentic and can be used for serious purposes like horoscope matching.

3. Personalized Horoscope & Predictions

Daily Predictions: The app provides daily personalized horoscope readings for the user based on their natal chart. This goes beyond the generic sun-sign horoscope – it uses the user’s Moon sign, Ascendant, and current planetary transits to craft a more relevant prediction
miracuves.com
. For example, if Jupiter is transiting their 10th house, the daily note might mention career growth opportunities. The daily prediction is written in a friendly, conversational tone (possibly AI-generated) to engage users
miracuves.com
miracuves.com
. It’s like a “daily weather forecast” for your destiny, tailored to the individual.

Monthly & Annual Horoscopes: Broader forecasts for the month and year will be available. These are based on slower-moving planets and general trends in the user’s chart. We can generate these using AI trained on astrological texts or have astrologer-curated content. For instance, a 2025 Yearly Horoscope section can summarize what major periods (dashas or transits) the user will go through, echoing what competitor apps offer
play.google.com
play.google.com
.

Life Predictions & Reports: In addition to time-based forecasts, the app can provide thematic reports – e.g., Career Report, Marriage Prospects, Health Outlook, etc. These sections analyze the Kundli for specific questions (like career) and provide insights (for example, “Mars in 10th house and strong Sun indicate a leadership role in career” along with any relevant dasha timing). Such content may be partially static (written by astrologers) and personalized by plugging in user’s details.

Dosha & Remedies: A very important aspect for many users. The app will automatically check for common astrological Doshas in the Kundli: e.g., Mangal Dosha (Mars affliction), Kaal Sarp Yog, Sade Sati (Saturn’s 7.5 year transit) etc.
play.google.com
. If any such condition exists, the app highlights it and provides an explanation of its meaning plus suggested remedies (like “You have Mangal dosha, which may delay marriage; remedy: perform XYZ puja or wear ABC gemstone”). Remedy information can be generic advice collected from astrological sources.

Notifications: Users can opt to receive a daily notification with a summary of their personalized horoscope (e.g., every morning at 7 AM). This notification might say something like “Good morning! Your stars today favor career decisions. Tap to read more.”
miracuves.com
. Tapping it opens the app to the detailed daily prediction. Similarly, we can notify about major upcoming events (e.g., “Jupiter entering your birth sign next week – big changes ahead!” for yearly transitions). These keep users engaged and returning regularly.

Personalization and Limits: Many of these predictions can be enhanced via the AI. The AI might generate answers to specific questions (via the chat feature, next section), whereas this section is more of an automated overview. We must be careful to manage expectations – e.g., include a disclaimer that predictions are for guidance and not absolute. Users should also be able to control what type of predictions they want to see (some may not want health-related predictions, etc., which could be a settings toggle for sensitive content).

4. General Horoscope (Sun Sign / Moon Sign Rashifal)

Daily/Weekly Rashifal: In addition to personalized readings, the app will offer the traditional Rashifal for all 12 zodiac signs (e.g., Aries/Mesh, Taurus/Vrishabh, etc.) in both English and Hindi. This is similar to what you find in newspapers or on AstroSage’s site – e.g., “Today Aries: You might find new opportunities at work…”. Users can read not just their own sign but others as well (some users like to check family members’ horoscopes or are simply curious).

Weekly and Monthly Horoscopes: General forecasts for each sign for the week and month. These are less personalized but useful for quick consumption. They will be written by astrologers or AI based on planetary transit in each sign (e.g., if Saturn is retrograde in Aquarius, the Aquarius weekly horoscope will reflect that).

Browsing UI: We will have a dedicated section where all signs are listed – possibly as 12 card buttons or a carousel – with their daily snippet. The user can tap a sign to expand full details and switch between day/week/month/year tabs. If the user has set their profile, that sign could be highlighted or shown first.

Localization: Rashifal will be available in Hindi as well, using the common sign names (Mesh, Vrishabh, etc.) so that users comfortable in Hindi can read in their language. For English users, both Western name and Sanskrit name can be shown for clarity (e.g., “Aries (Mesh)”).

Purpose: This section serves content even to those users who might not input birth details. It ensures even a casual user (who perhaps skipped profile creation) gets value from the app (they can still read generic horoscopes for their sun sign). It also complements the personalized predictions – one is not a replacement for the other; rather, they give different perspectives.

Updates: The content for these general horoscopes needs to be updated daily/weekly. We will either have an in-house astrologer team or use a reliable feed. Possibly, an AI model could generate these based on known transit interpretations and a prompt (this could be part of the AI feature in backend, but it’s separate from the user-facing AI chat). Astrotalk’s success partly comes from giving users a reason to check the app daily
miracuves.com
 – our rashifal section will serve that purpose for all users.

5. Panchang & Hindu Calendar (Offline Support)

Interactive Calendar: A full Hindu calendar (Panchang) is built into the app, which users can view in a familiar grid format (month view)
play.google.com
. Each date cell will display important info such as the tithi for that day (e.g., “Trayodashi”), festival or holiday name if applicable, and maybe moon phase icon. Users can scroll through months and years. The calendar can be switched between lunar mode and solar mode (for regional calendars) – e.g., choose between Vikram Samvat and Shaka era, or Amanta vs Purnimanta month delineations, depending on user’s preference
play.google.com
. This effectively can cater to regional variations like Gujarati calendar, Telugu Panchangam, Tamil Panchangam, Bengali Panjika, etc., by applying the corresponding settings
play.google.com
.

Daily Panchang Details: Tapping on a date (or on “Today”) brings up the Dainik Panchang details for that day. This includes the five Panchang elements: Tithi, Nakshatra, Yoga, Karana, and Var (weekday)
play.google.com
. Additionally, it shows sunrise and sunset times for the selected location, moonrise/moonset, the current Hindu month and year, and any special auspicious time windows (e.g., Abhijit Muhurat, Rahu Kaal, Gulikai, Yamaganda, etc.)
play.google.com
play.google.com
. The app will highlight if it’s an auspicious day or has any special yogas (e.g., mention if it’s a Pushya Nakshatra day or an Amrit Siddhi Yoga, etc., as Drik Panchang does
play.google.com
).

Festivals & Holidays: The calendar view and daily view will list all major festivals, vrats (fasts), and government holidays in India
play.google.com
. We’ll maintain a database of festivals for each year (with info on which ones are region-specific if needed). Users can tap on a festival name to see a short description of it. For example, on Diwali, the app might show “Diwali – the festival of lights, Amavasya of Kartik month – Muhurat: 7:15pm to 9:15pm for Lakshmi Puja.” Providing such cultural context makes the app more engaging and useful.

Add Personal Events (Tithi Reminder): Users can add a reminder for a personal event with a Hindu date. For instance, if someone’s birth tithi or a death anniversary needs to be observed yearly by the lunar calendar, the app can let the user create an event on that tithi. The app will then each year remind the user on that tithi (this feature is analogous to Drik Panchang’s “Add Tithi” reminder
play.google.com
). This is important for users who follow the Indian calendar for specific rituals.

Location & Offline Data: The Panchang data (sunrise/sunset, etc.) is location-dependent. The user can set their default location (either via GPS or choosing a city). The app will use this to calculate accurate times. We will include an internal atlas of latitude/longitude for major cities (or use Google Maps API for precise coordinates)
play.google.com
. Importantly, the calendar and panchang will be available offline – once the app is installed, it contains all the necessary data or calculation rules for at least a range of years (say 2020-2030). This means users do not need internet to check dates or tithis
play.google.com
. Only if they change location or year far out might it need to fetch additional data (which we can also package in updates). The app’s offline capability is a big plus for users in areas with poor connectivity or those who prefer not to use data.

Design: The calendar section will likely be a separate tab or screen. It might have a sidebar menu listing categories (Panchang, Festivals, Muhurat, etc.) or simply allow the user to navigate the calendar and click on dedicated sections for “Festivals List” or “Today’s Panchang.” We will ensure the design is clean (possibly with traditional motifs for aesthetic) but information-rich.

Accuracy: We will utilize well-known Panchang algorithms (such as those used by Drik Panchang) to ensure accuracy in calculations of tithi/nakshatra timings and festival dates. This includes accounting for DST (Daylight Savings) automatically where applicable
play.google.com
. Our data will be verified against trusted sources for correctness.

6. Kundli Matching & Compatibility

Horoscope Matching: The app offers a Kundli Milan (matchmaking) feature for checking compatibility between two individuals, which is especially useful for marriage purposes. Users can select any two saved profiles from their account (e.g., their own and a prospective partner’s) or enter new birth details for someone. The app will then compute the Ashtakoota Guna Milan score out of 36 points
play.google.com
. This includes calculating the eight Kutas (Varna, Vashya, Tara, Yoni, Graha Maitri, Gana, Bhakoot, Nadi) based on the two birth charts. The output screen will show the score (e.g., “24 out of 36 points match”) and highlight which areas matched well and which did not.

Detailed Compatibility Report: Beyond the numeric score, the app will provide a narrative on the compatibility. For example: “You have a Nadi dosha in this match, which traditionally is considered inauspicious for health of progeny. However, Graha Maitri is excellent, indicating good understanding between partners.” It will explain any Dosha found (like Nadi or Bhakoot dosha) and suggest potential remedies or interpretations (e.g., if both charts have the same Nadi maybe it’s not as bad, etc.). For users not versed in these terms, a simple language summary will be provided (like “Overall compatibility: Medium. Some astrological factors suggest caution.”).

Love Compatibility (Western astrology): As a fun add-on, we could include a simpler compatibility check based on zodiac signs (Sun-sign compatibility or Moon-sign compatibility). E.g., letting a user pick two sun signs to see general love compatibility. This is more for casual use and sharing on social media (like “Aries and Libra – 70% compatible!”). It’s not as detailed as Kundli Milan but popular among younger users.

Save Results: If a user performs a Kundli match, the result can be saved to their profile (especially if they matched two profiles from their saved list). For instance, if someone is comparing multiple prospects, they might save those analyses. The app can keep a history of matches done, with labels (e.g., Person A with Person B on date X). Drik Panchang’s app also saves matched results for future reference
play.google.com
.

UI Flow: The matchmaking feature may be accessible from the home or menu (e.g., a card saying “Match Making – check compatibility”). It will lead to a screen where the user selects two profiles or inputs details. After calculation, the compatibility report screen is shown with possibly an option to download the compatibility report as PDF to share with family.

Accuracy & Scope: Our algorithm for Kundli Milan will follow the classic Vedic system for authenticity. (Optionally, we might also incorporate modern considerations like Manglik matching – e.g., alert if one is Manglik and the other isn’t, etc.). We should make sure to clearly state that this is one method of compatibility and actual relationship success depends on many factors; this manages user expectations.

Future Extension: In future updates, we might extend compatibility to other types of matching (like friend compatibility, or business partnership compatibility using astrology). But initially, focus is on marriage matching, as that’s a primary use-case in India.

7. AI Astrologer – Chatbot Assistant

AI Consultation Feature: A standout feature of this app is the AI-powered Astrologer Chatbot. This allows users to have a conversation with an AI that acts like a virtual astrologer. Users can ask natural language questions about their life or horoscope and receive instant answers/advice. For example: “Q: I’m feeling stuck in my career, what does my Kundli suggest? A: Based on your chart, you’re running Jupiter Mahadasha which is favorable for education. Consider upskilling this year
play.google.com
.” The AI will utilize the user’s stored birth data (with permission) to give contextually relevant answers, or it can answer general questions if no personal data is provided.

Technology & Knowledge Base: The AI is built on a sophisticated language model (like GPT-4 or a fine-tuned variant) that has been trained on astrology texts, Kundli interpretation rules, and possibly our own content repository. It effectively has “learned” from classical astrology sources, so it can interpret planetary combinations, dashas, transits etc., similar to how a human astrologer would. For personalized queries, the backend will input the user’s key astrological info (planet positions, current dasha, etc.) into the prompt so the AI can factor those in. This feature essentially democratizes jyotish knowledge through AI, as AstroSage has done with their AI astrologer
play.google.com
play.google.com
.

Use Cases: Users can ask a wide range of questions, for example:

“What does this year have in store for me financially?”

“I have Saturn in my 7th house; what does that mean for my marriage?”

“When will I likely get married as per my Kundli?”

“Today’s panchang – is it a good day to start a new business?”

The AI will generate a helpful response, usually a few sentences or a short paragraph, addressing the question with astrological reasoning. It should sound empathetic and wise, like a seasoned guru but in user-friendly language.

Limits & Accuracy: Each user will have a limited number of free AI questions they can ask (for example, 3 questions per day for free users, subject to adjustment). This encourages usage but also showcases the feature’s value. The answers are generated based on patterns; while the AI is trained for astrological consistency, we will include a disclaimer that responses are AI-generated and for guidance only. The system will also implement some checks to avoid problematic advice (e.g., it should refrain from medical or legal specifics, and encourage seeking professional help where appropriate).

UI Design: The AI chat will have a dedicated screen with a chat interface. It will display a chat history between the user and the AI astrologer. The user types a question into a text box (support both English and Hindi queries since many users might ask in Hindi). After sending, an AI typing indicator can show for a moment, then the answer appears. The tone of the chatbot persona can be slightly formal/warm (possibly even allow the AI to have a name/persona like “AstroGuru”). Users can scroll up to see past Q&A. We might also provide quick suggestion buttons for common questions (like “What is my lucky number?” or “Tell me about my career”).

Monetization of AI Feature: This feature is a prime candidate for monetization. The app will implement a premium subscription or pay-per-question model for the AI chat. For example: users get X free questions. After that, they need to either watch an ad (maybe) or subscribe to continue unlimited queries. A Premium subscription (monthly/yearly) could offer unlimited AI chats along with other perks (ad-free experience, exclusive content, etc.). Alternatively, we can sell question packs (e.g., 50 questions for $5). The PRD leans towards a subscription as it builds recurring revenue and mirrors AstroSage’s approach where advanced features are paid.

Integration with Human Astrologers: Initially, the AI works alone. In future (with the guru marketplace), this chat interface might also be used to chat with a human. We should design it such that it could be extended – e.g., the UI might later allow switching between “AI” and “Live Astrologer” modes. For now, it’s just the AI behind it, but it sets the stage for the concept of on-demand consultation.

Example Interaction:

User: “AI Guru, my Kundli shows Shani Sade Sati starting – what should I expect?”

AI: “Your Sade Sati (Saturn’s transit over your moon) begins. Traditionally, this can be a challenging period bringing hard work and life lessons. You might face career hurdles or responsibilities. However, it also rewards you if you put in sincere effort. Don’t worry – many emerge stronger after Sade Sati. Focus on discipline and you’ll get through fine. Consider chanting Shani mantras on Saturdays for mental peace.”
This kind of answer mixes general astrology wisdom with a bit of personalized touch (if the AI knows the user’s Moon sign it can be more specific). We will test the AI thoroughly to fine-tune its responses.

8. Live Astrologer Consultation (Future Feature)

*(Note: This is a planned feature for a future phase, not in the initial launch.)

Astrologer Marketplace: The app intends to onboard real astrologers (“gurus”) whom users can consult via chat or live voice/video calls, similar to platforms like AstroTalk
miracuves.com
miracuves.com
. In the future, there will be a section listing available astrologers with their profiles – including photo, expertise (Vedic, Tarot, Numerology, etc.), experience, ratings, and per-minute or per-session charges. Users could browse and choose an astrologer based on their needs.

Scheduling/On-Demand: We plan to allow both instant consultations (if an astrologer is online) and scheduled appointments. For chat, the user would enter a chat queue with the astrologer and pay per minute or per question. For calls, they pay per minute of call time
miracuves.com
. This requires real-time communication features (likely using a service for VoIP).

UI & Flow: Once implemented, the home screen might feature a “Talk to an Astrologer” banner. Tapping it shows a list or categories (e.g., Love, Career, Vedic Astrologers, Tarot Readers). The user taps a profile to see details and an option to start a chat or call (with the rate clearly shown). After the session, the user can rate the astrologer and leave a review – building trust and accountability
miracuves.com
.

Monetization: The app will take a commission from these paid sessions. An in-app wallet or payment gateway will be integrated so users can pay seamlessly
miracuves.com
. Users might top-up their wallet or pay per session. Special offers or bundles (like discounted first call) can attract users to try this service.

Trust & Quality: We will verify all astrologers before onboarding (ID checks, interviews)
miracuves.com
. Their predictions need to be quality-checked initially. There should also be a mechanism for dispute resolution or refunds if a session is unsatisfactory. All chats should be encrypted end-to-end for privacy
miracuves.com
.

Why Future: While this feature is high impact (as seen by AstroTalk’s success), it is also complex to implement (requires building a supply side of experts and real-time comm infrastructure). Therefore, it’s slated for a later phase once we have a significant user base from the core features. We mention it in the PRD to ensure the initial design (especially navigation and data models) can accommodate it later (for example, prepare to have user accounts handle paid services, etc.). The initial release will focus on automated and free content (plus the AI), which itself is a lot of value.

9. Other Notable Features

Learning Resources: To increase engagement, the app can include an Astrology Learning section. This might have articles, glossaries, or even short video tutorials explaining astrology concepts (e.g., “What is a Nakshatra?”, “Basics of Palmistry”, etc.). AstroSage, for instance, offers lessons and content for those interested
play.google.com
. This feature can be community-driven or updated periodically, and helps to retain users by offering more than just personal predictions – it positions the app as an educational hub as well. (This is a nice-to-have feature that could be part of premium content or free for all.)

Notifications & Reminders: Apart from daily horoscope notifications mentioned, the app will send reminders for: upcoming festivals (from the calendar, e.g., “Tomorrow is Krishna Janmashtami”), personal event reminders user set (like a Tithi reminder or a custom note), and nudges like “Haven’t checked your horoscope in a while” to re-engage dormant users. All notifications will be configurable in settings (user can opt in/out).

Multi-Language Localization: The entire app interface and content will be available in Hindi and English at launch
play.google.com
. Users choose their preferred language on first use (and can toggle in settings). Key content like daily predictions, rashifal, panchang, AI responses, etc., will be generated or translated accordingly. Our aim is to eventually support other languages like Tamil, Kannada, Telugu, etc. (the architecture should allow adding languages easily by adding new localization files and content translations). Even the AI could answer in those languages if we integrate appropriate models. We know from competitor data that supporting major Indian languages is crucial
play.google.com
.

Offline Functionality: Offline usage is a notable requirement. The Hindu calendar, basic panchang data, and any saved Kundli/horoscope reports will be accessible offline. Users should be able to open the app in a no-internet scenario and still see, for example, today’s panchang and their natal chart (assuming it was generated prior or we include ephemeris data offline). The core calculations (planet positions, panchang) can be done offline by the app’s algorithm without needing server calls
play.google.com
. However, features like AI chatbot or content updates (daily rashifal text updates) will require connectivity – if the user is offline and tries AI chat, we will show a “You’re offline” message. We will cache certain content whenever possible (perhaps store the last week’s worth of daily horoscopes so even if offline, the user can see yesterday’s or today’s generic horoscope). Offline support differentiates us from many apps that won’t work without internet, and it’s especially important for users using the calendar on the go (e.g., when at a temple or pilgrimage with poor network).

User Interface & Experience: The app will have a clean, intuitive UI with likely a bottom navigation bar for major sections (Home, Horoscope, Calendar, Chat, Profile). Key screens like the Kundli display will be visually appealing yet information-dense (perhaps using cards or tabs to organize info so it’s not all on one long screen). We will use icons and illustrations (e.g., zodiac icons, a small icon for each planet) to make it engaging. The design will incorporate some cultural elements (like a subtle Sanskrit font for headings or a thematic color palette), giving it an authentic feel.

Security & Privacy: We take data security seriously in this app. All personal data (birth details, chat transcripts, etc.) will be stored securely (encrypted on device and in transit). If we implement cloud backup of charts or user data, it will be to secure servers with proper encryption. Any payment transactions for subscriptions or astrologer services will use secure payment gateways with PCI compliance. For the future live chat features, we will ensure end-to-end encryption of chat messages/calls
miracuves.com
 to protect user privacy. We will also follow relevant laws, e.g., not storing personal info without consent, giving users the ability to delete their account and data, etc. Building user trust is crucial, given that astrology often involves sharing personal life questions.

Performance: The app should be optimized for performance given the heavy calculations. Generating a Kundli should only take a second or two on a typical smartphone. UI interactions (scrolling through calendar, switching screens) should be smooth. We will possibly use native code or optimized libraries for calculations. The app should also be reasonably sized since it contains offline data (we’ll aim to compress the ephemeris and panchang data). On modern phones, the footprint should be manageable (~30-50MB if possible).

Compatibility: The app will support a wide range of devices (Android 7.0+ and iOS 13+ for example) to cover most of the market. It should also handle different screen sizes gracefully (e.g., more content can be shown on tablets).

Support & Feedback: Provide in-app support like an FAQ section (covering common questions about features or astrology terms). Also allow users to send feedback or contact support (especially if they face any calculation issues or have content questions). A community/forum feature is not planned initially, but we might include a link to a web forum or social media group for user discussions if that becomes relevant.

User Flow and Screen Details

This section describes the typical app flow and major screens the user will interact with, along with the elements and actions on each screen. The flow is designed to be intuitive, guiding the user from onboarding to deeper feature usage seamlessly.

 

1. Splash Screen & Language Selection:

The app launches with a splash screen displaying the app logo and maybe a tagline like “Your Personal Astrology Guide.” This appears for a couple of seconds.

If it’s the very first launch, the user is then taken to a Language Selection prompt (unless we default based on device locale). Here they can choose between English and Hindi (more languages will be listed as they become available). This choice sets the app’s language. (This screen can be a simple list or buttons for each language, possibly with the option to change later in Settings.)

2. Onboarding Carousel (Intro Slides):

(Optional but recommended) A brief onboarding carousel of 3-4 slides that highlight the key features: e.g., “Generate your Kundli in seconds,” “Daily personalized horoscope,” “Ask questions to our AI astrologer,” “Hindu calendar & panchang offline,” etc. Each slide has a graphic and short text. The last slide prompts the user to proceed to sign up. There will be a skip option to jump straight to the app.

3. Registration / Login Screen:

The user is presented with options to Sign Up or Log In. Sign-up methods: “Continue with Phone” (OTP verification), “Continue with Google”, or a classic email & password. We highlight that creating an account will let them save their data and get personalized predictions.

If the user chooses phone, they enter their number, receive OTP, verify and proceed. If Google, a standard OAuth flow. Logging in (for returning users) similarly offers phone (enter number to get OTP) or email/pw.

There’s also a “Continue as Guest” button for those who want to explore without registering. Guest users can use many features but will be reminded to sign up to save their profile or use premium features like AI after a point.

4. Profile Setup (Enter Birth Details):

After sign-up (or if continuing as guest, when they try to use a feature requiring birth data), the app will prompt for Birth Details to create the user’s primary Kundli. This is a form screen: fields for Name, Date of Birth (with date picker), Time of Birth (time picker, include option for unknown time if needed with some default assumption), Place of Birth (text field with auto-complete for cities or use GPS for current location).

The place field might integrate Google Maps API to fetch coordinates or use a built-in city database. If using GPS, user can allow location access to auto-detect city.

After entering details, an action button “Generate My Kundli” creates the profile. If some details are missing or out of range, validations will prompt (e.g., time not selected).

Once saved, the user’s Kundli is generated in the background. The next screen will likely be the Home or directly the Kundli summary (depending on design flow).

5. Home Dashboard:

The Home Screen serves as a dashboard with a snapshot of various features. It might contain:

A welcome message (maybe “Hello, [Name]!”) and today’s date, location, etc.

Daily Personalized Horoscope snippet: e.g., “Today: You might get a pleasant surprise at work. (Tap to read more)” – tapping this would go to the detailed daily horoscope page for the user.

Today’s Panchang summary: e.g., “Today is Ekadashi, Nakshatra: Rohini. Auspicious time 1:30-3:00 PM. (See Calendar)” – tapping opens the detailed Panchang screen for today.

Maybe a highlighted festival or event if today or tomorrow has one (e.g., “Tomorrow: Diwali – don’t forget to check auspicious puja times!”).

Quick Actions / Cards: We can have a set of icon buttons or cards linking to main sections: “My Kundli”, “Ask AI Guru”, “Match Making”, “Monthly Horoscope”, “Calendar”, etc. This acts as a shortcut menu. For example, a card that says “🔮 Ask the AI Astrologer” with a prompt like “When will I find love?” to entice usage. Or a card “💑 Check Compatibility – Kundli matching for marriage.”

Possibly a banner for any premium promotion (“Get unlimited questions with AI – Upgrade to Pro”).

The Home screen content is scrollable if many sections. It essentially surfaces bits of each feature to encourage exploration. It should be the default tab when the app opens (after first use).

6. Bottom Navigation:

At the bottom of the app, we will have a persistent navigation bar (for easy switching between main sections). Proposed tabs: Home, Horoscope, Calendar, Chat, Profile.

Home: (dashboard as described above)

Horoscope: This could directly open the personalized horoscope section or a menu of horoscope types (daily, weekly, etc.). Possibly we design it such that the “Horoscope” tab shows the user’s daily horoscope by default, with options to switch to other periods or see all zodiac signs.

Calendar: Opens the Panchang calendar view (month view of current month).

Chat: Opens the AI astrologer chat interface (and in future might list human astrologers as well). The tab icon could be something like a chat bubble or a guru icon. If the user hasn’t used AI before, it might show a welcome message like “Ask any question about your horoscope.”

Profile: Opens profile/settings page (with user’s name, perhaps their birth details summary, and various settings and saved items).

This bottom nav bar is visible on all main screens for quick switching. The currently active section’s icon is highlighted.

7. My Kundli Screen (Detailed Horoscope):

When the user navigates to view their full horoscope details (e.g., via a “My Kundli” button on Home or perhaps under Profile), they reach a screen that displays their Birth Chart and life report.

Layout: Likely a tabbed interface or scroll sections:

Kundli Chart tab: showing the graphical chart (North/South Indian style as per setting) with houses and planets. There might be a toggle to switch chart style on the fly, or a zoom feature. We may overlay degrees on planets if double-tapped (as AstroSage does
play.google.com
).

Planetary Details tab: a list of each planet with its sign, degree, nakshatra, house, and a short interpretation. E.g., “Sun – 15° Cancer (in 2nd House): Indicates wealth through family business.”

Dasha tab: showing current Mahadasha/Antardasha and a timeline of dashas. Possibly interactive to select different periods and see which planets are active.

Additional tabs like “Strengths” (Shadbala, etc.), or “Charts” (Navamsha and others) for advanced users, could be included but perhaps hidden by default under an “Advanced” expand section to keep UI cleaner for average users.

Reports tab: pre-composed life predictions such as personality overview, career, marriage, etc., derived from the chart. This is more narrative.

The screen might have an action bar with options: Share/Download (to export PDF of the Kundli report), Edit (to edit birth data if needed, e.g., if user realizes a time was off), and New Chart (shortcut to create another profile’s chart).

If multiple profiles are saved, there could be a dropdown at the top to switch between profiles, so the user can quickly view a family member’s chart, for example.

Performance: We ensure this screen loads quickly by computing all needed info at profile creation time (and updating if user edits details).

8. Daily Horoscope Screen:

This screen shows the detailed daily horoscope for the user. It can be accessed by tapping the snippet on Home or via Horoscope tab.

It will display a nicely formatted text (a few paragraphs) about the user’s day, divided into aspects if needed (e.g., Love: … Career: … Health: …). It may also show lucky color/number for the day, any do’s and don’ts, etc., which are often included in such horoscopes.

The user can navigate to previous or next day if curious (swipe or arrow buttons), or switch to weekly/monthly view (maybe via a dropdown or segmented control at top allowing “Daily | Weekly | Monthly | Yearly”).

If the user hasn’t provided birth details or is a guest, this section might instead show a prompt like “Get personalized horoscopes by creating your profile” and in the meantime perhaps show the generic sun-sign horoscope for their chosen sign.

We will also have an option here to view all 12 signs’ horoscopes for today (maybe a button “View all signs” that takes to a list of signs). Alternatively, the “Horoscope” tab might directly lead to a page that lists all sun-signs for the day, and the personalized one is just highlighted or separate. We need to integrate the general horoscope content in the UI in a coherent way – possibly splitting the Horoscope section into two subsections: “Mine” and “All Signs”.

The screen could feature an illustrative icon or image (like a generic zodiac illustration for the day) to make it visually appealing, since it’s mostly text content.

Users can share the horoscope text (share button to copy or send via messaging apps). People sometimes like to share their horoscope if it’s particularly relevant or interesting.

9. Horoscope (Zodiac) Selection Screen:

If a user wants to read generic horoscopes, we can have a screen showing 12 zodiac signs (with icons or artwork). This can appear when user taps something like “All Signs” or maybe directly when they tap the Horoscope tab (and then they can tap their sign).

Each sign icon might show a one-line teaser for today. For example, under “Aries” icon: “Today: A busy day at work may leave you tired.”, under “Taurus”: “Expect some good news in the evening.” etc.
miracuves.com
. We can scroll through or grid display them.

Tapping a sign leads to that sign’s full horoscope page, which looks similar to the personalized one but is general. From there, user can switch date ranges as well or change sign via a drop-down. Perhaps include an option “Set this as my sign” if the user never set a profile (for guest, to remember their sun sign).

This flow ensures even without profile, the Horoscope section is useful.

10. Calendar (Month View) Screen:

This is the main Panchang calendar interface. The top might have controls to change month and year (e.g., a toggle or swipe left-right to change month, and a year dropdown). By default, it opens at the current date/month.

The screen likely uses a familiar calendar grid (7 columns for days of week, etc.). Each cell (date) might display the date in Gregorian and the tithi or festival in a small font. If too much info, we might use a small dot or symbol on days that have something special and show details in a list below or on tap.

We may incorporate a small preview area below the calendar that, when you select a date, shows summary info (like “Pratipat, Krishna Paksha, [Festival Name]”).

The user can scroll vertically if we allow an agenda list below the calendar. Or we keep it simple where tapping a date opens a new screen (Daily Panchang detail).

There could be a floating action button or menu for calendar-related actions: e.g., a button “Today” to jump to today’s date, a button “Festivals” to see a full list of festivals of the year, or “Search” to find a festival or date.

11. Daily Panchang Detail Screen:

When a date is selected (or user taps “Today’s Panchang” somewhere), this screen shows detailed Panchang for that day.

It includes: the five elements (Tithi, Nakshatra, Yoga, Karana, Day) at sunrise and their end times if applicable, sunrise/sunset times, moonrise/moonset, the current Hindu date (e.g., Samvat 2078, Month – Bhadrapada, Paksha – Shukla, etc.), any special yogas or dur muhurts. This can be formatted in a list or card format for clarity.

If there’s a festival or event on that day, it will be highlighted at top (“Festival: [Name]”). If multiple, list them.

Auspicious and inauspicious time windows (Muhurat): likely a sub-section. E.g., “Shubh Muhurat: Abhijit 12:05-12:50; Rahu Kaal (inauspicious) 16:30-18:00; etc.”
play.google.com
.

Perhaps a note on the weekday lord (some panchang apps mention which deity’s day it is, e.g., Thursday – Guruvar, ruled by Jupiter).

The screen might allow switching location quickly if user wants to see panchang for another city (a small location icon to pick different city). But usually one location suffices.

There could be a share option here too, to share today’s panchang details with friends (some people do that on WhatsApp groups).

If the user clicked “Festivals” from calendar, it could open a screen similar to this but listing each festival of the month or year with dates.

12. Compatibility (Match Making) Screen:

The user accesses this via maybe the Home quick link or a menu item “Kundli Matching”. If the user has two profiles saved (like their own and a partner’s), we might pre-fill those, else the user selects profile1 and profile2 from dropdowns. There’s also an option “Enter new details” if one person is not in saved profiles – tapping that opens a mini form to input birth details for matching.

Once two profiles are set, the user taps “Match Horoscopes” and within moments the result is displayed on the same screen or a new result screen.

Match Result Screen: Shows the names of Person A and B, their birth details, and the score (e.g., “24/36 Gunas Matched”). Possibly display it as a rating or progress bar visually. Underneath, each of the 8 aspects can be listed with individual points (like “Nadi: 0/8 (Nadi dosha present)”, “Bhakoot: 7/7 (Excellent)”, etc.). Maybe color-code good vs bad scores.

Then a text summary interpretation as described earlier (which can scroll if long).

We include a note if any dosha that might need remedy is present (maybe highlight in red text).

There could be a “Save this Match” button to save it with a label (like store that these two profiles were matched). If they are both from saved profiles, we might auto-save the result in that profile’s section.

UI wise, this could either appear as a popup over the input screen or a new page. A straightforward approach is: input on one screen, then tap leads to a new screen for result, with a back arrow to go back if they want to try different profiles.

Also consider: if guest user, allow matching by entering both sets of data manually. That result can be shown but not saved unless they sign up. We might prompt them “Sign up to save this match result.”

Provide share option (some families share the Kundli Milan report with others).

13. AI Chatbot Screen:

The AI Astrologer chat interface is a key screen. When the user taps the Chat tab (or an “Ask AI” button), they come here. If it’s the first time, a welcome message from the AI might already be present: e.g., “Hello, I’m your Astro Guide. You can ask me questions about your horoscope or life. Try asking about your day or any concern.” This sets context.

The screen looks like a messaging app: past messages in a scrollable area, user input field at bottom, and a send button. The AI messages can be stylized (maybe with a small icon/avatar of a wise sage or a star icon) and user messages aligned opposite side.

If the user has remaining free questions, it might show somewhere “Free questions left: 2” or if none, show a lock icon or prompt to upgrade. We will implement logic to check their quota. On hitting the limit, when user tries to ask, we pop-up “You’ve reached the free question limit. Subscribe to AstroPro for unlimited guidance.” and offer purchase.

As the user enters a question and sends, the message appears in the thread, and then a “typing…” indicator or loading spinner shows that AI is working. Then the AI’s answer text appears. We will likely chunk long answers into paragraphs to improve readability.

We should allow basic text features like copy text (if user wants to save the advice) or maybe a thumbs-up/down feedback on the answer to help us improve the model over time (optional).

If the user switches away to another tab and comes back, the chat history persists (store it locally or in account if logged in). Possibly limit how far back it saves to avoid heavy storage use, or periodically summarize/prune if needed.

The user can clear the chat or start a “New session” if they want (some users might prefer a clean slate – we can have a trash or reset button).

Edge Cases: If AI cannot answer (like user asks something outside scope or there’s an error), the AI should respond with a polite message like “I’m sorry, I’m not able to answer that. Could you ask something else?” rather than failing silently.

This screen must handle both English and Hindi input/output. If needed, we auto-detect language or provide a language toggle for the AI (maybe not necessary if model can handle mixed languages as many Indians type Hindi in Latin script etc. We might use a transliteration or bilingual model to support that).

14. Profile & Settings Screen:

The Profile tab leads here. At the top, it could show the user’s name (or phone/email if name not set), and perhaps their zodiac sign or a profile pic (we might allow them to set an avatar or use an automatically assigned zodiac icon based on their sign).

Key info like birth date/time and location might be displayed for reference. An “Edit” button allows modifying those (if changed, we regenerate the Kundli and update predictions accordingly).

A section for Saved Profiles/Charts: listing the other profiles the user saved, with an option to add a new one. E.g., “+ Add New Kundli”. Each entry when tapped might navigate to that profile’s Kundli details. (Alternatively, we allow switching profiles in the My Kundli screen as mentioned, but having them listed here is nice too).

Subscriptions: If the user is on free tier, a banner or button “Upgrade to Premium” is shown with brief benefits (ad-free, unlimited AI, etc.). If already premium, it shows their plan and next billing date, etc., and maybe an option to manage/cancel.

Purchase History / Wallet: If we have in-app wallet (maybe later for live consultations), show current balance and top-up options. Initially, if only subscription is the model, we can skip wallet. But keep in mind for future.

Settings: Various app settings:

Language – switch between English/Hindi on the fly (the app may require restart or seamlessly change text if we have localization set up).

Notifications – toggle daily horoscope notification, event reminders, promotional notifications.

Chart Preferences – e.g., North vs South Indian chart default, whether to show outer planets, default ayanamsha (Lahiri vs others if we expose that)
play.google.com
play.google.com
, etc. Some of these advanced settings only advanced users care about, but including them will appeal to serious astrologers. We can group them under an “Advanced Settings” subsection.

Privacy/Security – manage permissions (location access on/off), option to request data deletion, etc.

Help/FAQ – link to help pages or contact support.

About – app version, developer info, maybe a rate-us link.

Logout button at the bottom for logged-in users, in case someone wants to switch account. If a guest user is viewing profile, they’d instead see a prompt to Sign In/Sign Up to save data.

The Profile screen thus combines both user data management and settings in one place, which is common in many apps.

15. Additional Flows:

Ads Display: Since free version may contain ads (unless we decide otherwise). Likely places: a banner ad at bottom of some screens (like horoscope or kundli screen), and/or an occasional interstitial ad after certain actions. We must ensure this doesn’t annoy to the point of user churn – possibly keep ads minimal in early versions. If user goes Premium, ads are removed. (Though not explicitly a screen, the flow of how ads show and can be closed is part of UX).

Error States: e.g., if no internet and user tries something that needs it (like AI chat or login), show a friendly error (“Internet connection needed. Please check your connection.”). If a calculation fails for some reason, handle gracefully (maybe allow retry, or in worst case, show “Could not generate chart. Please try different data or contact support.”).

Update Prompt: Over time, if we add features or fix Panchang data, we might prompt user to update the app. On major updates, show a dialog or an in-app notification about new features (like “New! Live astrologer chat now available”). This keeps users informed and engaged with updates.

The above covers the main screens and flows a typical user would experience. The navigation is designed such that a user can easily jump between getting their horoscope, checking a date in the calendar, or asking the AI a question, without getting lost. The integration of features is meant to feel cohesive (e.g., the home summarizes multiple aspects so user realizes all that’s available). Consistent design elements (like using the same zodiac icons or theme colors) across screens will ensure the app feels unified.

Technical Implementation & Algorithms (Kundli & Horoscope Calculation)

To deliver accurate astrological data, the app relies on robust algorithms and data sources. Below we outline how key calculations and the AI system will work:

Kundli (Birth Chart) Calculation Algorithm

Generating a Kundli involves astronomical calculations to determine planetary positions at the given birth date/time and location, followed by mapping those into astrological signs and houses:

Ephemeris Data: We will use a high-precision ephemeris (such as the Swiss Ephemeris library or NASA’s JPL DE ephemeris) to get the geocentric positions of planets. This can either be done via an embedded library or precomputed data tables within the app for the range of years needed (to allow offline use). The ephemeris gives the longitude of each planet (and possibly latitude and speed, though primarily we need zodiac longitude).

Ayanamsha & Zodiac: Since this is Vedic astrology (sidereal zodiac) for Kundli, we apply the chosen ayanamsha value (default Lahiri) to adjust from the tropical positions. Users can have the option to choose a different ayanamsha like Raman or KP
play.google.com
play.google.com
, but Lahiri will be default. After subtracting ayanamsha, we get the sidereal longitudes of planets, which correspond to positions in 12 signs (Aries 0° to Pisces 360°). Determining the sign is straightforward: 0-30° = Aries, 30-60 = Taurus, etc.

Ascendant (Lagna) Calculation: Using the birth date/time and location (latitude, longitude), we calculate the local sidereal time and then the ascendant degree. This involves some astronomy math: converting to Julian day, computing sidereal time, then using latitude to find which sign is rising. The ascendant degree gives the starting point of the 1st house. In North Indian chart style, houses are fixed to signs, so basically the ascendant sign and degree are noted. In South Indian style (rasi chart), the ascendant is marked in the appropriate sign box. Our calculation must account for time zones and any daylight savings offset if applicable (we can automatically handle DST as needed
play.google.com
).

House Division: For Vedic, typically whole-sign houses or equal houses are used (in classical Kundli, each house = one sign starting from ascendant). Some systems might use Placidus or others, but we likely stick to the traditional whole sign or equal houses approach, unless we incorporate Western astrology too. Given our focus, we will use the standard North/South Indian chart representation which effectively is whole sign.

Calculate Other Chart Points: Moon’s nakshatra is determined from Moon’s longitude (each 13°20' segment is a nakshatra). We can identify the Nakshatra and its pad (quarter). Also calculate varga charts like Navamsa: this is derived from main longitudes (we can either explicitly calculate or use known formulas to map positions to Navamsa placements).

Dasha Calculation: For Vimshottari Dasha, the algorithm uses the Moon’s nakshatra at birth and remaining balance of that mahadasha, then cycles through the sequence (Ketu -> Venus -> Sun -> etc.) for 120 years. We will implement this to list the Mahadasha/Antardasha periods. This is deterministic and we can generate the timeline easily to show in app (AstroSage does up to 5 levels of Vimshottari
play.google.com
, but we might just do 2 levels initially).

Output: The result of calculations is a data structure containing: each planet’s sign & degree, the ascendant sign & degree, lagna chart placements, Navamsa chart placements, current dasha, etc. This data structure feeds both the UI (to draw charts) and the interpretation engine (to produce text).

Accuracy Check: We should test our outputs against known example charts. The line from AstroSage suggests they’ve optimized so you don’t need to carry heavy books/tables
play.google.com
 – our app will achieve the same by doing all this computation internally or bundling the data. Provided we use a reliable library or thoroughly tested code, the calculations will be accurate to a few arc-seconds, which is more than enough for astrology purposes.

Horoscope Interpretation & AI Logic

Rule-Based Interpretations: A classic way to generate textual interpretations is to use a knowledge base of astrology rules. For example, if Mars is in the 7th house, combine with whether it’s in own/exalted sign to produce a line about marriage or partnerships. We can encode many such rules (perhaps via a database or script) to assemble a basic life report. However, doing this exhaustively is a large task. We likely will cover key points (like each planet in each house, major conjunctions) to build a sensible narrative.

AI-Generated Interpretations: Instead of solely rule-based text, we can leverage the AI. We might prompt an internal AI model with the raw chart data to “explain this person’s horoscope.” However, for efficiency, we might not do this heavy lifting on-device for every user’s full chart due to cost. Instead, we might pre-generate generic text for combinations and just fill them in. The AI shines more in the interactive Q&A.

Daily Predictions Algorithm: For personalized daily horoscopes, we use transits: On each day, planets have certain positions (which we know from ephemeris). Compare these with user’s birth chart. E.g., if today Mars is transiting the user’s 10th house, plus the user is in a Venus dasha, plus Moon is in their 4th house today – our algorithm weighs these factors and picks relevant themes (career energy from Mars, emotional focus on home from Moon, etc.) to craft a message. We might use a template approach first: mapping certain transit combos to pre-written outcomes. Additionally, an ML model could be trained to predict sentiments (good/neutral/bad day) based on transits to automate some content. Astrotalk’s mention of AI daily predictions
miracuves.com
 suggests using AI to make these more engaging and unique each day. We will likely generate the daily horoscope via a cloud function that composes it (possibly using GPT with a prompt that includes the user’s transit info each day, ensuring consistency with astrological principles).

General Horoscope Content: For general sun-sign horoscopes, these can be written by an astrologer for each sign for each day/week, or generated by an AI in batch. Since they don’t require personal data, it’s easier to automate. For example, we know the Moon’s sign of the day and other major aspects – a prompt to AI like “Write a one-paragraph horoscope for Aries for [date] considering that the Moon is in Taurus and Venus is trining Mars” could produce decent output. We will have an editor review or some rules to avoid wildly inaccurate text. Alternatively, partner with an astrology content provider or license content if needed, but AI could significantly help here.

Kundli Matching Algorithm: The compatibility (guna matching) is a deterministic calculation. We assign points based on well-known criteria (Varna 1, Vasya 2, etc.) comparing the two charts (mostly based on Moon signs and Nakshatras of the couple). Our algorithm will compute each of the 8 kootas and sum points. If needed, include logic for exceptions (like Nadi dosha cancellation). This is straightforward once we have both charts computed. We just have to be careful to implement the rules correctly.

AI Chatbot Engine: The heart of the AI feature is a combination of prompt-engineering and possibly fine-tuning. The approach: when a user asks a question, we form a prompt that includes relevant data. For instance, if user asks “What career should I pursue?”, our system will retrieve that user’s birth chart data (maybe in a human-readable form like “User is Aries ascendant, Jupiter in 10th house in Capricorn (exalted), etc.”). We then prepend a carefully written system prompt to the AI that might say: “You are an expert Vedic astrologer. You have the user’s birth chart details as follows: [data]. The user asks: [question]. Give a thoughtful astrological advice based on the chart, in a friendly tone.” Then we call the AI model (which could be an API call to OpenAI/others, or a local model if feasible) to get the answer.

Fine-tuning & Knowledge: We may fine-tune a model on Q&A pairs from astrology domain to improve its reliability. Also, to ensure the AI’s information is correct, we might inject some curated text (like general interpretations or guidelines) into the prompt. It should ideally cite astrological reasons in answers (“because your Saturn is in Aries…” etc.) to appear authentic.

Limiting Scope: We will restrict certain queries: health or medical queries we can answer in only generic terms and advise consulting a doctor if needed. Same for very sensitive questions (the AI will be instructed not to give fatalistic or dark predictions, to avoid harm). These content constraints will be part of the AI’s system prompt or post-processing.

Continuous Learning: We could allow the AI to learn from user feedback. If many users ask similar questions, we can refine the answer templates. Over time, the AI could be improved via more training data (perhaps transcripts of human astrologer sessions if we get any).

Performance: Each AI query will likely be a network call (to our server or third-party) unless we embed a model. To keep it reasonably fast, we will use concise prompts and possibly a moderately sized model for quick response. A response time of 5-10 seconds is acceptable given the complexity of what it’s doing. We’ll show a typing indicator to manage user expectation during that wait.

In summary, the app’s “astrology engine” combines classical algorithms (for chart calculations and matchmaking) with modern AI (for interpretation and interactive Q&A). By doing heavy calculations on-device (which is possible even offline
play.google.com
), we ensure users can get results anytime. By using AI carefully, we provide a personalized, conversational layer that sets the app apart and leverages the vast astrological knowledge base in a scalable way. 
miracuves.com
miracuves.com

Monetization Model

To make the app sustainable, we incorporate monetization in user-friendly ways:

Freemium Approach: The app is free to download and offers the majority of features for free (Kundli generation, basic horoscopes, panchang, etc. are free and unrestricted). This builds a large user base. Monetization kicks in for premium value-add features and removal of inconveniences like ads.

Advertisements: The free version will display some ads (e.g., banner ads on horoscope pages or intermittent full-screen ads at natural breaks). We will be careful to not overwhelm the user – the content is the priority. Ads provide baseline revenue given the likely large number of free users. Users who find ads annoying will have an incentive to upgrade.

Premium Subscription (AstroPro): We will offer a subscription plan (either monthly, yearly, or both) that unlocks additional benefits:

Unlimited AI Chat: Free users get limited AI questions (e.g., 3 per day or 10 per month). Premium users can ask the AI as many questions as they want, making this a key selling point.

Ad-Free Experience: Subscribers will not see ads in the app, resulting in a cleaner interface and faster use.

Exclusive Content: Possibly offer detailed personalized reports or advanced astrology content (like more in-depth predictions, or access to courses) only for subscribers. For instance, a 20-page personal horoscope PDF or yearly transit report could be a premium perk.

Early access to new features: When we launch something new (like maybe tarot readings or the live astrologer feature), give subscribers priority or discounts.

We’ll price the subscription competitively for the Indian market (perhaps INR 199/month or INR 999/year as a ballpark, subject to market research). The app will show prompts to subscribe at strategic points (like when they run out of AI queries or when a big ad is about to show, offering “Go ad-free and get unlimited guidance – subscribe now”). This follows models of other apps where a small percentage convert to paid, but those support the app’s development.

In-App Purchases: Aside from subscription, we can offer one-time purchases for specific items: e.g., Ask an AI question on demand (for those who don’t want a subscription, maybe Rs.10 per extra question). Or purchase specific detailed report PDFs (like a personalized yearly report) for a fee. These micro-transactions allow monetizing users who have a specific need but won’t commit to a subscription.

Astrologer Consultation Fees: Once the live astrologer marketplace is introduced, that becomes another revenue stream. Typically, the user will pay per minute for calls/chats (say an astrologer charges ₹20/minute, the app keeps a commission, e.g., 30%). We will integrate a wallet or direct payment for each session. This can become a significant revenue source as users pay for personalized attention.

Promotional Tie-ins: In future, the app could also sell astrology-related products or services (like gemstones, puja services, etc., via affiliate partnerships), but that’s beyond the current scope. It’s worth noting AstroSage and others do have such offerings. It could be explored if user base is large and engagement is high (as an example, recommending a gemstone in a remedy and offering a way to buy it).

Retention vs Monetization Balance: We will ensure that free users still get a lot of value (so they remain and bring others via word-of-mouth). The paywall is on advanced/extra usage, which serious users will be willing to pay for. By analyzing usage patterns, we can adjust limits or add new premium features to optimize conversion. For instance, if AI chat is extremely popular, we might introduce different tiers of subscription with more features. Or if users want one-off consultations, we might allow pay-per-consult.

Transparency: All paid features will be clearly marked. We’ll avoid any bait-and-switch (like letting a user do a lengthy input then saying “pay to see result” unexpectedly). If something is premium (like maybe a full 15-page Kundli report), we’ll indicate it upfront. Building user trust is important for long-term monetization success.

Future Scope and Enhancements

While the initial version of the app is already feature-rich, we have plans to expand its capabilities further, ensuring we stay ahead of the competition and cater to evolving user needs:

Live Astrologer Services: As detailed, integrating live astrologer consultations is a big next step. In addition to one-on-one sessions, we can consider live group webinars or sessions in the app (e.g., an astrologer giving a weekly astrology forecast or a class on astrology basics, which users could pay to join). This fosters community and increases time spent in-app
miracuves.com
.

Additional Languages: Expand the app’s localization to include more Indian languages like Tamil, Telugu, Kannada, Bengali, Gujarati, etc. Also possibly add voice input/output in these languages for the AI (voice questions, spoken answers) to improve accessibility.

Western Astrology & Other Systems: Currently, focus is Vedic. In future, we might incorporate Western astrology options (tropical zodiac, different house systems) to appeal globally
miracuves.com
. Also adding numerology, tarot readings, palmistry scans etc. could widen the app’s appeal as a holistic “occult app”. These could be separate modules or mini-apps within (for example, a palm reading AI that scans your palm).

Community & Social Features: Introduce a community section where users can share experiences or astro-memes, or see daily astro posts. Perhaps a forum where our AI or astrologers answer publicly posted questions (like a Quora for astrology). Users could follow astrologer profiles or join groups (e.g., all Aries ascendant users group). This could drive engagement by making it partially a social platform around astrology.

Improved AI & Personalization: Continuously improve the AI’s accuracy and add features like voice interaction (“Hey AstroGuru, what’s my forecast for tomorrow?”). Personalization can go deeper with AI analyzing user behavior – e.g., which aspect user cares about (career vs love) and emphasizing those in content.

Offline Expansion: While panchang is offline, in future we might allow the entire app (except live features) to work offline by syncing content whenever online. That could mean caching several days of horoscope, maybe even a distilled version of AI on-device for certain queries (if technology permits). This would truly empower users in low net zones.

Astrology Research Tools: For the truly advanced users or astrologers, the app could add tools like transit charts (current planetary positions), personalised transit alerts (“Saturn transiting your Moon coming up”), or even allow them to compare two charts (synastry) beyond just the point-based match. These features target power users and could be premium.

Wearables & Integrations: Long-term, we might integrate with voice assistants (Alexa/Google Assistant skills for daily horoscope) or wearable devices (a watch complication showing daily star rating or something). Not a priority but an idea to keep in mind.

Regulatory Compliance: As we expand, ensure compliance with any local laws (e.g., if any regulation comes around astrology advice, privacy laws, etc.). Also, ethically, we might include in future some mental health resources – e.g., if a user seems very depressed asking negative questions repeatedly, the AI or app might gently prompt considering professional help. This is more of a responsible design consideration for the future as AI and astrology intersect in advising people.

Each of these enhancements would be detailed in subsequent PRDs when we plan to implement them. The current PRD focuses on the foundation that will make these future additions possible.

References & Research Sources: This PRD has been informed by features of existing astrology apps and industry insights. For instance, the AstroSage Kundli app’s feature list
play.google.com
play.google.com
 guided our inclusion of comprehensive Vedic tools and AI integration. The Astrotalk platform provided inspiration for live chat, call features, and monetization strategies
miracuves.com
miracuves.com
. Drik Panchang’s app demonstrated the viability of a fully offline Hindu calendar with multilingual support
play.google.com
play.google.com
, which we have adopted. We also noted trends such as rising user interest in personalized astrology content
miracuves.com
 and the use of AI for daily horoscopes
miracuves.com
 and consultations
play.google.com
. These insights have been woven into the requirements to ensure our app is modern, competitive, and aligned with user expectations.