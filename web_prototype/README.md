# PlayGarden

A small, calm collection of ten learning games for children aged three to five. The whole thing is built to be safe for little hands: big buttons, clear feedback, short play loops, and nothing that can take a child out of the app. No ads, no links, no chat, no purchases, and no data collection.

## What's inside

| File | Purpose |
|------|---------|
| `index.html` | The single-page shell. Three screens (home, grown-ups, game) live in one document and we toggle the active one. |
| `style.css` | All the styling. Bright primaries, oversized tap targets, rounded corners, reduced-motion support. |
| `games.js` | The game engine and all ten games. Each game is a small object that draws into the shared game screen. |
| `manifest.webmanifest` | Web app manifest so it can be added to a home screen and run full-screen. |
| `icon.svg` | App icon. |

## The ten games

1. Tap the Colour: colour recognition
2. Count the Friends: counting one to five
3. Find the Shape: shapes
4. Animal Sounds: animals and their sounds
5. Memory Match: short-term memory
6. Letter Hunt: letters
7. Big or Small: comparing sizes
8. What Comes Next? (simple patterns)
9. Pop the Bubbles: tap and pop, fine motor practice
10. Finger Painting: free drawing and creativity

## Running it

There's no build step and no dependencies. Open `index.html` in any modern browser, or serve the folder over a simple static server:

```bash
# any one of these works
python3 -m http.server 8000
# then visit http://localhost:8000
```

On a phone or tablet, open the page and use "Add to Home Screen" to get the full-screen, app-like experience.

## Design notes

- **Tap targets** are kept large (88px minimum) because preschoolers don't have precise aim yet.
- **Feedback** is immediate and obvious: a correct answer gets a green pop, a wrong one a gentle shake, and finishing a round brings up a reward pop-up with stars.
- **Stars** are pure encouragement. There is nothing to unlock or spend, and a grown-up can reset them from the For Grown-ups screen.
- **Reduced motion** is respected for children who are sensitive to movement.

## A note on safety

Everything stays inside the app. There are no external links a child can wander off to, no advertising, and no personal information is collected or stored anywhere off the device. Stars are kept in the browser's local storage only.
