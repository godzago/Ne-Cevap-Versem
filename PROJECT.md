# PROJECT.md: "Ne Cevap Vereyim?" Mobile App

## 1. PROJECT OVERVIEW
"Ne Cevap Vereyim?" is a hybrid utility/entertainment Micro-SaaS mobile application built with Flutter. The app helps users craft the perfect replies to text messages or screenshots they receive in various social and professional scenarios. 

### Core Tech Stack
*   **Frontend:** Flutter & Dart (Cross-platform, initially targeting Google Play Store, then Apple App Store).
*   **Architecture:** MVVM (Model-View-ViewModel) or Clean Architecture.
*   **State Management:** Riverpod or BLoC (Lightweight, decoupled state).
*   **Backend / Proxy:** Serverless Node.js / Firebase Cloud Functions (To secure AI APIs and handle business logic).
*   **Monetization:** RevenueCat (Subscription & Consumable Token Model).

---

## 2. APP ARCHITECTURE & MODES (PERSONAS)
The application logic revolves around 4 distinct AI sub-agents/personas. Each persona represents a specific real-world dynamic:

### Mode 1: Patron / Yönetici (The Corporate Diplomat)
*   **Target Audience:** Corporate workers, freelancers, employees.
*   **Tone:** Highly professional, politically correct, setting firm boundaries without being aggressive.
*   **Goal:** Reject overtime, ask for promotions, or handle micro-management gracefully.

### Mode 2: Sevgili / Flört (The Romantic Navigator)
*   **Target Audience:** People in dating phases or long-term relationships.
*   **Tone:** Empathetic, flirting, clear but non-toxic communication.
*   **Goal:** Decode passive-aggressive partner messages, handle arguments, or write witty dating app replies.

### Mode 3: Pasif-Agresif (The Sarcastic Duo)
*   **Target Audience:** Users dealing with toxic friends, annoying relatives, or social media trolls.
*   **Tone:** Sharp, witty, passive-aggressive, "drop the mic" (laf gediğine) style.
*   **Goal:** Delivering clever comebacks while maintaining plausible deniability.

### Mode 4: Mülakat (The HR Specialist)
*   **Target Audience:** Job seekers, interviewees.
*   **Tone:** Confident, structured, professionally safe.
*   **Goal:** Deflecting trap questions (e.g., employment gaps, salary expectations) into professional strengths.

---

## 3. CORE USER FLOW & FEATURE SPECIFICATIONS
1.  **Dashboard (Home Screen):**
    *   A cartoonish/caricature grid layout displaying the 4 modes using specific asset images.
    *   Clicking a card navigates the user to the dedicated **Chat Simulation Screen** for that mode.
2.  **Chat Interface:**
    *   **Input Types:** 
        *   Manual text entry (TextField).
        *   Image/Screenshot upload (OCR engine converts WhatsApp/Slack/Tinder screenshots to text via Backend/AI Vision).
    *   **Action:** User submits the incoming text -> App triggers the AI API Proxy.
    *   **Output:** The app displays **3 distinct alternative responses** in color-coded chat bubbles:
        *   *Option A:* Safe & Political (Politik & Kibar)
        *   *Option B:* Short & Direct (Net & Kısa)
        *   *Option C:* Witty / Creative (Yaratıcı / Esprili)
    *   **UX Feature:** A prominent "Copy" button next to each bubble for one-tap clipboard execution.

---

## 4. TECHNICAL REQUIREMENTS FOR AI AGENTS (BUILDING THE BACKEND & API)

### ⚠️ CRITICAL SECURITY RULE
*   **DO NOT** make direct HTTP requests to OpenAI/Anthropic/Gemini APIs from the Flutter client. 
*   **MUST** route all requests through a secure Backend Proxy (Node.js / Firebase Cloud Functions) to protect API Keys and handle request throttling.

### Free / MVP AI Infrastructure
To run the MVP on a zero-budget or free tier, the backend agent will implement one of the following wrappers:
1.  **Google Gemini API (Free Tier):** Highly generous free tier limits for text processing.
2.  **Groq Cloud API:** Provides lightning-fast inference on open-source models (Llama 3, Mixtral) with extensive free-tier limits.
3.  **Hugging Face Inference API:** Alternative fallback for open-source LLMs.

### LLM Prompt Structure (System Instructions)
The backend proxy must pass a structured `System Prompt` depending on the selected persona:

## 5. MONETIZATION, RATE LIMITING & STATE MANAGEMENT IMPLEMENTATION

### 5.1 RevenueCat & Subscription Architecture
The app uses `purchases_flutter` for monetization. The paywall must trigger programmatically under the following conditions:
* **Daily Free Limit:** Maximum 3 standard text replies per day (Reset time: 00:00 UTC).
* **Premium Locked Features:** * Any request originating from Mode 1 (Patron) and Mode 4 (Mülakat).
    * Any image upload / OCR request across all modes.
* **Entitlement ID:** `premium_access`

### 5.2 Local Storage & Free Credit Tracking
Before dispatching any request to the backend proxy, the local storage service must validate the user's remaining credits.
* **Package:** `shared_preferences`
* **Keys:** * `int_remaining_credits`: Tracks remaining daily requests (Default: 3).
    * `string_last_request_date`: Stores the last request date (Format: YYYY-MM-DD) to handle daily resets.

### 5.3 State Management & Data Flow Diagram
The application utilizes Riverpod/BLoC to manage the UI state seamlessly without tightly coupling the presentation layer with the business logic.

```json
{
  "system_prompt": "Sen 'Ne Cevap Vereyim?' uygulamasının [MOD_ADI] yapay zeka asistanısın. Görevin, kullanıcının sana gönderdiği mesajlara verilebilecek en iyi 3 alternatif Türkçe cevabı üretmektir. Çıktıyı kesinlikle belirtilen JSON formatında vermelisin.",
  "response_format": {
    "option_1_kibar": "Politik ve profesyonel/kibar cevap metni...",
    "option_2_net": "Kısa, net ve doğrudan cevap metni...",
    "option_3_yaratici": "Esprili, yaratıcı veya duruma göre zekice cevap metni..."
  }
}
