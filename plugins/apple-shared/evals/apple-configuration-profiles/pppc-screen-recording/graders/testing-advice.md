---
type: llm
focus: last_message
---
Check each claim about the agent's testing advice:

1. It says this profile only takes effect when delivered by an MDM server (for example, scoping it to a test Mac in the MDM). Installing it by double-clicking the file or through System Settings does not work for privacy (TCC/PPPC) payloads.
2. It does not tell the admin to install the profile with the `profiles` command-line tool (`profiles install` / `profiles -I`) as the test method.
3. It tells the admin that users still have to switch Screen Recording on themselves, but no admin credentials are needed.

Pass only if all three claims hold.
