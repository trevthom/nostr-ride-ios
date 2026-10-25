# NostrRide for iOS

The iOS shell for **NostrRide** — one app with two faces, **Ride** (a passenger)
and **Drive** (a driver). It wraps the web app in a Capacitor shell so iOS lets it
keep the location, and the ride's payment loop, running with the screen off.

## Where the real files are

This repo is the **Mac-side build**. The Xcode project, `Info.plist`, the icons and
the background-location code live next to the web app so the two shells cannot
drift apart:

> `trevthom/nostr-ride` → **`native/ios`**, documented in `native/ios/README.md`

`setup.sh` checks the app out, builds it, installs that shell and syncs CocoaPods.
Nothing committed here is a copy of it.

## Requirements

- macOS with **Xcode 15+** (`xcode-select --install`)
- **CocoaPods**: `sudo gem install cocoapods`
- **Node 22.23.4 or newer** (`node -v`)
- A free Apple ID to run on your own iPhone; a paid Apple Developer account for
  TestFlight and the App Store

## Build it

```bash
bash setup.sh
```

(Or `chmod +x setup.sh` once and run `./setup.sh`.)

That clones `trevthom/nostr-ride` into `app/` (reusing it if it is already there),
runs `npm ci && npm run build`, copies this repo's shell settings in, installs
Capacitor, copies the build into the Xcode project, runs `pod install`, and opens
`app/native/ios/App/App.xcworkspace`.

Pin a different commit with `NR_REF=<tag> bash setup.sh`; use a fork with
`NR_REPO=<git url> bash setup.sh`.

After changing the web app: `cd app && npm run build && cd native && npx cap copy ios`,
then run from Xcode. The shell **embeds** the build — it never loads the site from a
server, because the page holds keys and money.

## Sign it

In Xcode: target **App** → **Signing & Capabilities** → tick *Automatically manage
signing*, choose your team, and change the bundle id `app.nostrride` to something
unique to you (for example `com.yourname.nostrride`). **Once a build is on the App
Store that id is permanent.**

To run on a phone: plug it in, select it (not the simulator — the simulator has no
real GPS), enable Developer Mode on the iPhone (Settings → Privacy & Security),
and trust the certificate (Settings → General → VPN & Device Management).

## The location prompts

The first launch asks **While Using**. When a ride starts the app escalates to
**Always**: that is what lets the page keep running — and the rider keep paying the
fare — with the phone in a pocket. Declining is not fatal: unpaid ticks are paid
when the app next wakes, because the payment loop pays every ride that still owes.
iOS will also remind the person periodically that the app uses location in the
background. That is iOS, not a bug.

## App Store notes

- **Background location reason** (asked by both stores): the driver's position is
  shared with their rider during a trip, and the ride is measured on the rider's own
  phone. Keep the wording in `Info.plist` true if the behaviour changes.
- **Guideline 4.2 (minimum functionality)** is the real risk for a web app in a
  shell. The defence: a continuous background location session under an Always
  permission, a ride measured and paid while the phone is locked, and a start with
  no network. Expect to explain it once.
- **Encryption**: App Store Connect asks on every submission. The app uses standard
  cryptography only (schnorr signatures, NIP-44/NIP-49, Cashu blind signatures) and
  adds no proprietary cipher.
- **No push notifications**, by design: there is no server to send one.

## Not verified here

This machine has no Xcode, so the project has never been compiled. Treat the first
Mac build as a setup step, not a release. Real background behaviour — battery, the
order of the two prompts, a locked screen — has to be tried on a phone.
