---
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Write, Edit, Glob, Grep, Bash, WebFetch, Skill]
runs: 3
---
A teammate built this baseline profile for our new Macs. Can you review it before I upload it to our MDM and commit it to our config repo? Just tell me what's wrong; don't rewrite it.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>AutoJoin</key>
			<true/>
			<key>EncryptionType</key>
			<string>WPA2</string>
			<key>Password</key>
			<string>Spring2026!</string>
			<key>PayloadDisplayName</key>
			<string>Corp Wi-Fi</string>
			<key>PayloadIdentifier</key>
			<string>com.example.baseline.settings</string>
			<key>PayloadType</key>
			<string>com.apple.wifi.managed</string>
			<key>PayloadUUID</key>
			<string>9B2E4F61-3C7A-4D8E-A1B5-6C9D2E7F4A13</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>SSID_STR</key>
			<string>ExampleCorp</string>
		</dict>
		<dict>
			<key>PayloadDisplayName</key>
			<string>Restrictions</string>
			<key>PayloadIdentifier</key>
			<string>com.example.baseline.settings</string>
			<key>PayloadType</key>
			<string>com.apple.applicationaccess</string>
			<key>PayloadUUID</key>
			<string>9B2E4F61-3C7A-4D8E-A1B5-6C9D2E7F4A13</string>
			<key>allowAirDrop</key>
			<false/>
		</dict>
	</array>
	<key>PayloadDisplayName</key>
	<string>Example Baseline</string>
	<key>PayloadIdentifier</key>
	<string>com.example.baseline</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>5E8A1D3C-7B2F-4C6E-9A4D-2F1B8C3E6D70</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
```
