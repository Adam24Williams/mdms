# MDM Admin Skills

A collection of agent skills that help device-management administrators do day-to-day work on the Platforms they run, starting with Jamf Pro and Fleet.

## Language

### Platforms and protocols

**Platform**:
A device-management product an admin operates and that skills target, such as Jamf Pro or Fleet.
_Avoid_: MDM (as the umbrella term), vendor, tool, server

**MDM**:
The device-management protocol defined by an OS vendor (Apple MDM, Windows MDM) that a Platform speaks to enroll and command devices.
_Avoid_: using "MDM" to mean the Platform itself

**Admin**:
The person who operates a Platform and uses the skills.
_Avoid_: user (ambiguous with end users of managed devices), operator

### Skills

**Skill**:
A single packaged unit of instructions (and optional supporting files) an agent loads to help an Admin with one kind of task.
_Avoid_: prompt, command, recipe

**Platform Skill**:
A Skill written for exactly one Platform, using that Platform's own concepts.
_Avoid_: vendor skill

**Shared Skill**:
A Skill whose subject is the same regardless of Platform, such as configuration profile payloads, declarations, or device scripts.
_Avoid_: generic skill, common skill, vendor-neutral skill

**Read Skill**:
A Skill in which the agent never changes a live Platform itself; it explains, queries, or authors artifacts that reach the Platform only through the Admin's own review or pipeline.
_Avoid_: safe skill, knowledge skill

**Write Skill**:
A Skill in which the agent itself changes state on a live Platform, always after presenting a Change Plan and receiving explicit confirmation.
_Avoid_: action skill, mutating skill

**Change Plan**:
The statement a Write Skill presents before acting: which object changes, how, its scope, and how many devices are affected. Not a Terraform plan: a Change Plan precedes a change the agent itself makes.
_Avoid_: preview, dry run, diff

**Terraform plan**:
The set of creates, updates, replacements and deletes that Terraform computes for a configuration against a live Platform.
_Avoid_: Change Plan, diff

**Destructive Command**:
A device command that erases, locks (including Lost Mode), clears passcodes on, or unmanages devices, deletes a user and its data from a device, or bulk-deletes device records; no Skill ever sends one.
_Avoid_: dangerous action, risky command

**Verified Version**:
The Platform version a Skill was last checked against.
_Avoid_: supported version, compatible version

### Distribution

**Plugin**:
An installable bundle of Skills; one per Platform, plus one for Shared Skills.
_Avoid_: package, pack, module

**Marketplace**:
This repository as an installable catalog of Plugins.
_Avoid_: registry, store

**Companion Plugin**:
A Plugin published outside this Marketplace that a Plugin here recommends installing alongside it, such as `jamf-cli-skills` for live Jamf Pro operations.
_Avoid_: dependency, partner plugin

**Team Repo**:
An Admin team's own repository that enables Plugins from the Marketplace for everyone who works in it.
_Avoid_: customer repo, consumer repo
