---
type: llm
focus: last_message
weight: 2
---
Check each claim about the agent's final reply:

1. It says Fleet supports this today, through its Google conditional access integration.
2. It says the feature covers company-owned mobile hosts (iPhones, iPads or Android phones), and doesn't contradict that it needs Fleet Premium or that personally owned hosts aren't marked as managed. The Admin already said they run Premium, so the reply needn't repeat it.
3. It says where to connect it: **Settings > Integrations > Conditional access** in the Fleet UI, or the REST API, or GitOps.

Pass only if all three claims hold. Fail if it says Fleet can't do this or that it needs a third-party identity provider instead.
