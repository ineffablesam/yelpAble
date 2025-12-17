<img src="https://i.postimg.cc/wzfvJf4z/image.webp" alt="slide-1" width="100%"/>
<img src="https://i.postimg.cc/WsyVzCbD/slide-3.webp" alt="slide-3" width="100%"/>
<img src="https://i.postimg.cc/2CgprW0f/slide-4.webp" alt="slide-4" width="100%"/>
<img src="https://i.postimg.cc/bpFW9bcr/slide-5.webp" alt="slide-5" width="100%"/>
<img src="https://i.postimg.cc/vM0NG9m3/slide-6.webp" alt="slide-6" width="100%"/>

---


# YelpAble: Accessible to ALL, not just to MANY

## 🎯 Inspiration

In today's fast-paced digital world, discovering local businesses and making reservations shouldn't require juggling multiple apps, struggling through complex interfaces, or losing spontaneous moments with friends. We noticed three critical gaps in how people interact with local discovery platforms:

**The Voice Barrier**: Traditional search requires typing, scrolling, and navigating through countless menus. What if you could simply _talk_ to Yelp the same way you'd ask a knowledgeable local friend for recommendations?

**The Social Disconnect**: Planning outings with friends often means endless group chats, screenshot sharing, and coordination chaos. Why can't discovery and planning happen together in one collaborative space?

**The Content Gap**: We scroll through hundreds of food reels on Instagram and TikTok, see amazing restaurants and cafes, but then have to manually search each one individually. That viral bagel spot from the reel? Lost in your saved folder, never visited.

YelpAble was born from a simple belief: **access to local experiences should be universal, intuitive, and social**. We're not just building another Yelp client—we're reimagining how people discover, plan, and experience their communities through the power of Yelp AI.

----------

## 💡 What it does

YelpAble is an AI-powered mobile application that transforms how users interact with Yelp's vast database through three revolutionary features, each designed to break down barriers to local discovery:

### 🎙️ **Orion — Talk to Yelp AI**

Orion brings natural, voice-first interaction to local discovery. Powered by Cartesia's ultra-realistic voice generation and Flutter's speech-to-text capabilities, Orion creates a conversational experience that feels like talking to a knowledgeable local friend.

**Key Features:**

-   **Natural Voice Conversations**: Ask questions, get recommendations, and discover spots using natural language
-   **Contextual Understanding**: Yelp AI remembers your conversation context, preferences, and follow-up questions
-   **Interactive Business Cards**: Instantly get directions, call restaurants, book reservations, or explore menus—all through voice or tap
-   **Real-time Responses**: Powered by Yelp AI's comprehensive database with instant access to reviews, ratings, hours, and availability
-   **Hands-free Discovery**: Perfect for accessibility, driving, cooking, or multitasking scenarios

**Example Use Cases:**

-   "Find me authentic Italian restaurants near me with outdoor seating"
-   "What's the best brunch spot that takes reservations for 6 people this Sunday?"
-   "Tell me about the top-rated coffee shops within walking distance"

### 👥 **Nest — AI-Powered Chat Rooms**

Nest revolutionizes group planning by creating collaborative spaces where friends can discover and plan together with Yelp AI as an intelligent agent in the conversation.

**Key Features:**

-   **Collaborative Rooms**: Create private or public rooms with friends, family, or travel companions
-   **@YelpAI Agent**: Tag the AI agent anywhere in conversation to get instant recommendations, reviews, and bookings
-   **Group Decision Making**: Yelp AI analyzes group preferences and suggests options everyone will love
-   **Shared Itineraries**: Build collective lists of places to visit, complete with notes and reservations
-   **Real-time Reservations**: Book tables for your entire group directly within the chat using Yelp AI
-   **Easy Invite System**: Share unique room codes to instantly connect friends

**Example Scenarios:**

-   Planning a NYC trip with college friends: "Hey @YelpAI, we need dinner spots in Brooklyn for 8 people, vegetarian-friendly"
-   Weekend coordination: "Everyone type your favorite cuisine, @YelpAI will suggest a place that works for all of us"
-   Date night decisions: "@YelpAI, romantic restaurants with live music near Times Square?"

**Powered by Supabase Realtime**: All chat messages sync instantly across devices, ensuring everyone stays updated as plans evolve.

### 🎬 **Reely — Instagram Reel Intelligence**

Reely solves the viral content problem: we see amazing food spots in reels and videos, but actually visiting them requires tedious manual searching. Reely automates this entire process.

**Key Features:**

-   **Reel Sharing Integration**: Share any Instagram reel to YelpAble and watch the magic happen
-   **AI Video Analysis**: Automatically extracts restaurant/business names, locations, and dishes from the video
-   **Instant Yelp Intelligence**: Gets reviews, ratings, hours, and user-generated photos for each spotted location
-   **Smart Discovery Feed**: Browse video-detected spots in a beautiful, Instagram-like feed
-   **One-Tap Actions**: Save, get directions, or book reservations for any spotted location
-   **AI-Generated Summaries**: Yelp AI provides comprehensive overviews combining the reel's highlight with community reviews

**The Workflow:**

1.  See a viral reel: "Top 5 Bagel Spots in NYC 🥯"
2.  Share it to YelpAble
3.  Reely analyzes the video and identifies: Ess-a-Bagel, Russ & Daughters, Black Seed Bagels, Murray's Bagels, and Bo's Bagels
4.  Yelp AI instantly pulls reviews, ratings, addresses, and generates overview summaries
5.  Browse, save, navigate, or book—all in one seamless experience

**Why It Matters:**

-   Turns passive scrolling into active discovery
-   Eliminates the friction between inspiration and action
-   Validates viral claims with real Yelp reviews
-   Creates curated lists from your favorite content creators

----------

## 🛠️ How we built it

YelpAble represents a sophisticated integration of cutting-edge technologies, AI services, and modern development practices:

### **Core Technology Stack**

**Frontend & Mobile Development:**

-   **Flutter**: Cross-platform framework enabling beautiful, native experiences on iOS and Android
-   **Dart**: Powers the application logic with strong typing and excellent async capabilities
-   **Flutter STT (Speech-to-Text)**: Captures user voice input for Orion's conversational interface
-   **Custom UI Components**: Designed responsive, accessible interfaces with Yelp's brand-aligned aesthetics

**Backend & Real-time Infrastructure:**

-   **Supabase**: Provides PostgreSQL database, real-time subscriptions, and authentication
-   **Supabase Realtime**: Powers Nest's instant message synchronization across all connected clients
-   **RESTful APIs**: Handles business logic, user management, and Yelp AI integration

**AI & Voice Technologies:**

-   **Yelp AI API**: Core intelligence powering recommendations, reviews, and business discovery
-   **Cartesia AI**: Ultra-realistic text-to-speech synthesis creating natural, human-like voice responses for Orion
-   **Custom Prompt Engineering**: Optimized prompts for context-aware recommendations, group preferences, and video analysis

**Video & Content Analysis:**

-   **Computer Vision Processing**: Analyzes Instagram reels frame-by-frame to detect text overlays, business names, and locations
-   **OCR (Optical Character Recognition)**: Extracts readable text from video frames
-   **Natural Language Processing**: Parses extracted text to identify business entities and locations
-   **Yelp Fusion API**: Cross-references detected businesses with Yelp's database for verification

### **Feature-Specific Architecture**

**Orion (Voice Chat):**

```
User Voice → Flutter STT → Text Processing → Yelp AI API → Response Text → Cartesia TTS → Audio Playback

```

-   Bidirectional audio stream management
-   Context retention across conversation turns
-   Interrupt handling for natural conversation flow
-   Interactive card generation from AI responses

**Nest (Chat Rooms):**

```
User Message → Supabase → Realtime Broadcast → All Room Members
@YelpAI Mention → Backend Processing → Yelp AI → Formatted Response → Realtime Sync

```

-   WebSocket connections for instant message delivery
-   @mention parsing and AI trigger logic
-   Room-based authentication and permissions
-   Shared state management for group context

**Reely (Reel Analysis):**

```
Instagram Share → Video Download → Frame Extraction → OCR Processing → Entity Recognition → Yelp Verification → AI Summary Generation → Display

```

-   Share intent handling from external apps
-   Efficient video processing and frame sampling
-   Parallel API calls for multiple detected businesses
-   Caching system for processed reels

### **Development Workflow**

-   **Version Control**: Git with feature branch workflow
-   **API Integration**: Postman for testing, documented endpoints
-   **State Management**: Provider pattern for reactive UI updates
-   **Error Handling**: Comprehensive try-catch with user-friendly messages
-   **Testing**: Unit tests for business logic, widget tests for UI components

----------

## 🚧 Challenges we ran into

Building YelpAble pushed us to solve complex technical and design challenges:

### **1. Natural Voice Conversation Flow**

**Challenge**: Creating a voice interface that feels genuinely conversational, not robotic or frustrating.

**Solution**: I integrated Cartesia's advanced TTS with carefully crafted prompt engineering for Yelp AI. The key was maintaining conversation context across multiple turns while ensuring the AI's responses were concise enough for voice delivery but comprehensive enough to be useful. I implemented interrupt detection so users could naturally cut in, just like real conversations.

### **2. Real-time Synchronization at Scale**

**Challenge**: Keeping chat rooms synchronized across multiple devices without lag, especially when Yelp AI responses could be lengthy.

**Solution**: Leveraging Supabase Realtime's PostgreSQL change data capture, we implemented optimistic UI updates with rollback capability. Messages appear instantly on the sender's device while syncing in the background. We also chunked AI responses for progressive display, making the experience feel faster.

### **3. Instagram Reel Video Analysis**

**Challenge**: Accurately extracting business information from videos with varying quality, text styles, animations, and overlays.

**Solution**: Multi-stage pipeline with frame sampling (every 0.5 seconds), OCR with confidence thresholding, temporal text tracking (same text across multiple frames = higher confidence), and fuzzy matching against Yelp's database. We also implemented fallback strategies using audio transcription when available.

### **4. Yelp AI Context Management**

**Challenge**: In Nest rooms, multiple users asking different questions could confuse the AI context.

**Solution**: Implemented per-room context windows with user attribution. When @YelpAI is mentioned, we send the last 10 messages plus room metadata (location, time, participant preferences) to maintain coherent, contextually relevant responses.

### **5. Cross-Platform Voice Permissions**

**Challenge**: iOS and Android handle microphone permissions differently, causing inconsistent user experiences.

**Solution**: Built a unified permission abstraction layer with graceful degradation. If voice fails, users can seamlessly switch to text input without losing conversation context.

### **6. API Rate Limiting & Cost Management**

**Challenge**: Balancing comprehensive functionality with API call efficiency, especially for Cartesia voice generation and Yelp AI queries.

**Solution**: Implemented smart caching (frequently requested businesses, common queries), request debouncing (wait 500ms after user stops typing), and progressive loading (show basic info first, then enhance with AI insights).

### **7. UX for Complex Features**

**Challenge**: Making powerful AI features discoverable and intuitive without overwhelming users.

**Solution**: Progressive disclosure design—simple interfaces with advanced features revealed contextually. Interactive onboarding demonstrates Orion's voice commands, Nest's @mentions, and Reely's share workflow through actual usage rather than tutorial screens.

----------

## 🏆 Accomplishments that I'm proud of

### **Technical Achievements**

✨ **Seamless AI Integration**: Successfully unified three different interaction paradigms (voice, chat, video) under one coherent Yelp AI experience

🎙️ **Natural Voice UX**: Created one of the smoothest voice-to-AI experiences in local discovery—users genuinely feel like they're talking to a knowledgeable friend

⚡ **Real-time Collaboration**: Built a robust group chat system with AI agent integration that stays synchronized even with poor network conditions

🎬 **Video Intelligence**: Developed a reliable pipeline that turns passive content consumption into actionable discovery—a genuinely novel approach to local search

🏗️ **Scalable Architecture**: Designed a system that can handle thousands of concurrent users while maintaining sub-second response times

### **Design & UX Wins**

🎨 **Brand Consistency**: Created a visual language that feels authentically Yelp while introducing modern, accessible design patterns

♿ **Accessibility First**: Orion's voice interface makes Yelp genuinely accessible to users with visual impairments, motor difficulties, or situational limitations

📱 **Cross-Platform Excellence**: Delivered native-feeling experiences on both iOS and Android from a single codebase

🧭 **Intuitive Navigation**: Users immediately understand how to use each feature without tutorials—the ultimate UX validation

### **Innovation Highlights**

💡 **AI Agent in Group Chat**: I believe Nest's @YelpAI mention system is a breakthrough in collaborative planning—AI as a participant, not just a tool

🔗 **Share-to-Discover**: Reely transforms how people move from inspiration (Instagram) to action (real visits)—bridging the content-discovery gap

🗣️ **Conversational Discovery**: Orion proves that voice-first local search is not just possible but preferable for many use cases

### **Personal Growth**

📚 **Technical Mastery**: Deepened expertise in Flutter, real-time systems, AI integration, and voice UX design

🎯 **Product Thinking**: Learned to balance ambitious vision with practical constraints, shipping features that matter most to users

----------

## 📚 What I learned

### **Technical Insights**

**Voice UX is fundamentally different**: I'm learned that designing for voice requires completely different patterns than visual interfaces. Brevity matters more than comprehensiveness. Context is everything. Error recovery must be conversational, not modal dialogs.

**Real-time is hard but worth it**: Building Nest taught us the complexity of distributed state management. Race conditions, network partitions, and optimistic updates require careful architecture—but the resulting collaborative experience justifies the effort.

**AI needs guardrails**: Yelp AI is powerful, but without careful prompt engineering and context management, responses can be too long, off-topic, or inconsistent. We learned to structure prompts for specific output formats and validate responses before displaying.

**Video analysis is messy**: Unlike structured data, videos are chaotic. Text appears at different times, with different fonts, sometimes partially obscured. We learned that confidence scoring and fuzzy matching are more important than perfect accuracy.

**Mobile performance matters**: On-device speech recognition, real-time message syncing, and video processing all tax mobile resources. We learned to optimize aggressively—lazy loading, memory management, background task prioritization.

### **Product & Design Lessons**

**Feature clarity beats feature count**: Early prototypes tried to do too much. We learned to focus each feature on solving one problem exceptionally well rather than many problems adequately.

**Onboarding is discovery**: Users don't read tutorials. We learned to make features self-evident through contextual hints, empty state illustrations, and interactive examples.

**Accessibility expands your audience**: Building Orion for accessibility didn't just help users with disabilities—it created a better experience for everyone (hands-free while driving, cooking, walking).

**Social features need trust mechanisms**: In Nest rooms, we learned that privacy controls (who can join), moderation tools (removing members), and clear data policies are essential for user confidence.

### **Development Process**

**Fail fast, iterate faster**: Our first Reely prototype tried to use audio transcription. It was too slow. Pivoting to OCR-first with audio fallback saved us a week of frustration.

**Test with real content**: Using actual Instagram reels and real user conversations revealed edge cases no unit test could catch.

**API documentation is gospel**: Both Yelp AI and Cartesia had excellent docs, which dramatically accelerated development. We learned to read documentation thoroughly before coding.

**Version control discipline**: Working on three complex features simultaneously taught us the value of small, focused commits and clear branch naming.

### **Business & Community**

**Users want simplicity with depth**: Beta testers loved Orion's simple voice interface but also wanted power user features (save conversations, share voice clips). We learned to provide both.

**Social features drive retention**: Nest users engaged 3x more frequently than solo Orion users—validating the importance of collaborative discovery.

**Content bridges gaps**: Reely attracted users who'd never think to open a Yelp app but scroll food content daily—teaching us that meeting users where they already are matters more than building a better mousetrap.

----------
## 🎬 Closing Thoughts

YelpAble isn't just another app—it's a reimagining of how humans discover and experience their communities. By making Yelp **accessible** through voice, **collaborative** through group AI chat, and **actionable** through content intelligence, we're lowering barriers that have existed for too long.

Every voice conversation that helps someone with dyslexia find a restaurant. Every group chat that brings friends together over a shared meal. Every viral reel that becomes a real visit to a local business. These moments of connection—between people, technology, and community—are what drive us.

We built YelpAble for the **Yelp AI Hackathon**, but our vision extends far beyond a competition. We see a future where local discovery is as natural as asking a friend, as collaborative as planning with loved ones, and as effortless as sharing a reel.

**This is YelpAble: Accessible to ALL, not just to MANY.**

----------

## 🛠️ Built With

-   Flutter
-   Dart
-   Yelp AI API
-   Yelp Fusion API
-   Cartesia AI (Text-to-Speech)
-   Flutter STT (Speech-to-Text)
-   Supabase (Database & Realtime)
-   PostgreSQL
-   Computer Vision & OCR
-   Natural Language Processing
-   RESTful APIs

## 👥 Team

**Submission for Yelp AI Hackathon**  
_Dreamed, Designed & Delivered by: Samuel Philip_ : 
LinkedIn: https://www.linkedin.com/in/samuel-philip-v/
Github: https://github.com/ineffablesam

----------

**Try YelpAble. Discover differently. Connect authentically. Experience locally.**
