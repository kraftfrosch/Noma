Noma — Product Design Requirements (PDR)

1. One-liner
   AI coach for organized athletes. Plans, adapts, and explains training with precision and clarity.

2. Problem
   Existing fitness apps are generic and static. Athletes waste time planning sessions and balancing recovery. They need a reliable, minimal app that thinks and adapts like a real coach.

3. Users
   Young professionals training in gym, HIIT, or endurance sports. Time-constrained, semi-competitive, data-aware, seeking structure without noise.

4. Value Proposition
   Personalized AI conversation that remembers preferences and training style.
   Instant editing and re-planning through dialogue.
   Transparent reasoning for every workout.
   Minimal, modern interface focused on clarity and trust.

5. Scope v1
   Platform: iOS (SwiftUI).
   Design: Liquid glass interface. Navigation bar and floating AI button are a single integrated element (latest Apple pattern).
   Tabs: Workout Plan (active), Results/Progress (stub), Profile (stub).
   Interaction: Users chat with AI coach to generate, reorganize, or edit workouts.
   Editing: No diff screens. Subtle rollback arrows allow undo/redo of recent AI or manual edits.
   Workout Plan View:
   Scrollable list of workout cards.
   Each card: Title, Type, Subtype, Duration, Key Metrics (km, intervals, exercises, rounds).
   Simple check-off for completion.
   Workout Details:
   Clean layout.
   Exercises with names, reps, sets, weights, times, intensities.
   Optional manual edit (delete/add/reorder).
   AI “Why” explainer per workout and per exercise.
   Trust pattern: Each element can reveal reasoning in a consistent way without clutter.
   Planning horizon: One week ahead.
   No start workout flow, post-session input, integrations, or monetization.

6. Out of scope v1
   Live workout tracking.
   Device sensor streaming.
   Social features.
   Nutrition.
   Web app.

7. UX requirements
   Information clarity first. No crowded UI.
   Consistent “Explain” affordance on cards and details.
   Week mental model: mapping of sessions into AM / Day / PM buckets.
   Fast edit loop: from any card → AI edit → preview diff → apply.
   Completion is a single tap with optional feedback prompt.

8. Activity Categories
   Category Subcategories
   Gym Volume Push, Pull, Legs, Core, Full Body
   Gym Max Strength Push, Pull, Legs, Core, Full Body
   Gym HIIT (Cardio, Strength&Cardio)
   Run Base Z2, Intervals Z4/5
   Bike Base Z2, Intervals Z4/5
   Swim Base Z2, Intervals Z4/5
   Each workout defines number of reps and weights where relevant.
   Recovery logic and scheduling are fully handled by AI (no hard-coded rules).

9. AI coaching
   Memory: persistent athlete profile, preferences, injury history, modality mix.
   Capabilities: generate plan, reschedule week, modify single workout, swap exercises, adjust intensities/durations, enforce recovery constraints.
   Guardrails: respect progressive overload, modality interference rules, taper logic, and recovery windows.
   Explanations: concise rationale with references to user history and constraints.
   Voice-first: interactions with the AI are very conversational as a real voice dialogs as the main modailty will be voice first
