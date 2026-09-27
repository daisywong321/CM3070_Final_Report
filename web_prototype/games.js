/* =====================================================================
   PlayGarden: game engine plus the ten learning games
   ---------------------------------------------------------------------
   Written from scratch in plain JavaScript, no outside libraries needed.
   The whole thing runs on one small engine: every game just supplies a
   title and a start() function, and shares the same sound, speech, star
   and reward bits. Stars are kept in a simple variable for the session
   so that nothing about the child is ever saved or sent anywhere.
   ===================================================================== */
(function () {
  "use strict";

  /* ---------- small helper shortcuts ---------- */
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const el = (tag, cls, html) => { const n = document.createElement(tag); if (cls) n.className = cls; if (html != null) n.innerHTML = html; return n; };
  const rand = (n) => Math.floor(Math.random() * n);
  const pick = (a) => a[rand(a.length)];
  const shuffle = (a) => { a = a.slice(); for (let i = a.length - 1; i > 0; i--) { const j = rand(i + 1); [a[i], a[j]] = [a[j], a[i]]; } return a; };
  const range = (n) => [...Array(n).keys()];

  /* ---------- the only state we keep this session ---------- */
  let stars = 0;
  let soundOn = true;

  /* ---------- sound: short tones (Web Audio) plus spoken prompts ---------- */
  let actx = null;
  function ac() { if (!actx) { try { actx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) {} } return actx; }
  function beep(freq, dur = 0.16, type = "sine", vol = 0.18) {
    if (!soundOn) return;
    const c = ac(); if (!c) return;
    if (c.state === "suspended") c.resume();
    const o = c.createOscillator(), g = c.createGain();
    o.type = type; o.frequency.value = freq;
    o.connect(g); g.connect(c.destination);
    const t = c.currentTime;
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + 0.02);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    o.start(t); o.stop(t + dur + 0.02);
  }
  const sndGood = () => { beep(660, .12, "sine"); setTimeout(() => beep(880, .16, "sine"), 110); };
  const sndWin  = () => { [523, 659, 784, 1046].forEach((f, i) => setTimeout(() => beep(f, .18, "triangle"), i * 120)); };
  const sndOops = () => { beep(300, .18, "sawtooth", .12); };
  const sndTap  = () => beep(520, .06, "sine", .1);

  function say(text) {
    if (!soundOn) return;
    try {
      const u = new SpeechSynthesisUtterance(text);
      u.rate = .9; u.pitch = 1.25; u.lang = "en-US";
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
    } catch (e) {}
  }

  /* ---------- the confetti shower for a job well done ---------- */
  function confetti() {
    const colors = ["#ff5a5f", "#ffc93c", "#36c98e", "#4a8cff", "#9b6cff", "#ff7fb6"];
    for (let i = 0; i < 36; i++) {
      const c = el("div", "confetti");
      c.style.left = Math.random() * 100 + "vw";
      c.style.background = pick(colors);
      c.style.animation = `fall ${1 + Math.random() * 1.2}s ${Math.random() * .3}s ease-in forwards`;
      c.style.transform = `rotate(${rand(360)}deg)`;
      document.body.appendChild(c);
      setTimeout(() => c.remove(), 2600);
    }
  }

  /* ---------- stars and the reward pop-up ---------- */
  function addStars(n) { stars += n; $("#starNum").textContent = stars; bumpStar(); }
  function bumpStar() { const s = $(".star-counter"); s.style.transform = "scale(1.18)"; setTimeout(() => s.style.transform = "", 220); }

  function reward(earned, msg) {
    addStars(earned);
    $("#rewardEmoji").textContent = pick(["🎉", "🌟", "🎈", "🏆", "🦄", "🌈"]);
    $("#rewardText").textContent = msg || pick(["Great job!", "You did it!", "Wonderful!", "Hooray!", "Super!"]);
    $("#rewardStars").textContent = "⭐".repeat(Math.max(1, Math.min(earned, 5)));
    $("#reward").classList.add("show");
    sndWin(); confetti(); say(msg || "Great job!");
  }
  function hideReward() { $("#reward").classList.remove("show"); }

  /* ---------- moving between the screens ---------- */
  let currentGame = null;
  function show(id) {
    $$(".screen").forEach(s => s.classList.remove("active"));
    $("#" + id).classList.add("active");
    window.scrollTo(0, 0);
  }
  function goHome() { hideReward(); window.speechSynthesis && window.speechSynthesis.cancel(); currentGame = null; show("screen-home"); }
  function openGame(g) {
    currentGame = g;
    $("#gameTitle").textContent = g.title;
    show("screen-game");
    g.start();
  }
  function setPrompt(html) { $("#prompt").innerHTML = html; }
  function stage() { const s = $("#stage"); s.innerHTML = ""; return s; }

  /* keeps track of how far along a game is: play `rounds` rounds, then reward the child */
  function makeRunner(rounds, perStar = 1) {
    return { rounds, done: 0, perStar,
      next() { this.done++; return this.done >= this.rounds; },
      finish(g) { reward(Math.max(1, Math.round(this.rounds * this.perStar)), pick(["Great job!", "You finished!", "Amazing!"])); } };
  }

  /* =====================================================================
     CONTENT: the colours, animals, shapes and so on that the games draw from
     ===================================================================== */
  const COLORS = [
    { name: "red", hex: "#ff5a5f" }, { name: "orange", hex: "#ff8f3c" },
    { name: "yellow", hex: "#ffc93c" }, { name: "green", hex: "#36c98e" },
    { name: "blue", hex: "#4a8cff" }, { name: "purple", hex: "#9b6cff" },
    { name: "pink", hex: "#ff7fb6" }, { name: "teal", hex: "#2ec5d3" },
  ];
  const ANIMALS = [
    { e: "🐶", n: "dog" }, { e: "🐱", n: "cat" }, { e: "🐮", n: "cow" },
    { e: "🐷", n: "pig" }, { e: "🐸", n: "frog" }, { e: "🦆", n: "duck" },
    { e: "🐘", n: "elephant" }, { e: "🦁", n: "lion" }, { e: "🐵", n: "monkey" },
    { e: "🐰", n: "rabbit" }, { e: "🐻", n: "bear" }, { e: "🐝", n: "bee" },
  ];
  const ANIMAL_SOUNDS = [
    { e: "🐶", s: "Woof woof", n: "dog" }, { e: "🐱", s: "Meow", n: "cat" },
    { e: "🐮", s: "Moooo", n: "cow" }, { e: "🐷", s: "Oink oink", n: "pig" },
    { e: "🐸", s: "Ribbit", n: "frog" }, { e: "🦆", s: "Quack quack", n: "duck" },
    { e: "🦁", s: "Roar", n: "lion" }, { e: "🐝", s: "Bzzzz", n: "bee" },
  ];
  const SHAPES = [
    { n: "circle",   svg: '<circle cx="50" cy="50" r="38"/>' },
    { n: "square",   svg: '<rect x="14" y="14" width="72" height="72" rx="6"/>' },
    { n: "triangle", svg: '<polygon points="50,12 90,86 10,86"/>' },
    { n: "star",     svg: '<polygon points="50,8 61,38 93,38 67,58 77,90 50,70 23,90 33,58 7,38 39,38"/>' },
    { n: "heart",    svg: '<path d="M50 84C28 66 14 54 14 38a18 18 0 0 1 36-8 18 18 0 0 1 36 8c0 16-14 28-36 46z"/>' },
    { n: "diamond",  svg: '<polygon points="50,8 90,50 50,92 10,50"/>' },
  ];
  const shapeSVG = (s, color) => `<svg viewBox="0 0 100 100" width="74" height="74" fill="${color}">${s.svg}</svg>`;

  /* =====================================================================
     GAME 1: Tap the Colour
     What the child practises: recognising colours and learning their names
     ===================================================================== */
  const gColor = {
    id: "color", title: "Tap the Colour", emoji: "🎨", color: "var(--c-red)", skill: "Colours",
    start() {
      this.run = makeRunner(5);
      this.round();
    },
    round() {
      const choices = shuffle(COLORS).slice(0, 4);
      const target = pick(choices);
      setPrompt(`Tap the <b style="color:${target.hex}">${target.name}</b> one! <small>Find the colour</small>`);
      say("Tap the " + target.name + " one");
      const s = stage();
      const wrap = el("div", "options cols-2");
      choices.forEach(c => {
        const b = el("button", "opt");
        b.style.background = c.hex; b.style.minHeight = "120px";
        b.setAttribute("aria-label", c.name);
        b.onclick = () => this.answer(b, c.name === target.name);
        wrap.appendChild(b);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) {
        btn.classList.add("correct"); sndGood(); say("Yes!");
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 700);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 2: Count the Friends
     What the child practises: counting one to five and knowing the numerals
     ===================================================================== */
  const gCount = {
    id: "count", title: "Count the Friends", emoji: "🔢", color: "var(--c-blue)", skill: "Counting",
    start() { this.run = makeRunner(5); this.round(); },
    round() {
      const n = 1 + rand(5);
      const a = pick(ANIMALS);
      setPrompt(`How many ${a.n}s? <small>Count them out loud!</small>`);
      say("How many " + a.n + "s?");
      const s = stage();
      const show = el("div", "center");
      show.style.fontSize = "clamp(2rem,11vw,3.4rem)";
      show.style.lineHeight = "1.4";
      show.style.marginBottom = "var(--space-5)";
      show.textContent = a.e.repeat(n);
      s.appendChild(show);
      const opts = shuffle([n, ...shuffle(range(6).map(x => x).filter(x => x !== n && x >= 1)).slice(0, 2)]);
      const wrap = el("div", "options cols-3");
      opts.forEach(o => {
        const b = el("button", "opt", String(o));
        b.onclick = () => this.answer(b, o === n);
        wrap.appendChild(b);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) { btn.classList.add("correct"); sndGood(); say(btn.textContent);
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 800);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 3: Find the Shape
     What the child practises: telling everyday shapes apart
     ===================================================================== */
  const gShape = {
    id: "shape", title: "Find the Shape", emoji: "🔷", color: "var(--c-teal)", skill: "Shapes",
    start() { this.run = makeRunner(5); this.round(); },
    round() {
      const choices = shuffle(SHAPES).slice(0, 4);
      const target = pick(choices);
      setPrompt(`Find the <b>${target.n}</b> <small>Tap the matching shape</small>`);
      say("Find the " + target.n);
      const s = stage();
      const wrap = el("div", "options cols-2");
      choices.forEach(c => {
        const b = el("button", "opt", shapeSVG(c, pick(COLORS).hex));
        b.style.minHeight = "120px";
        b.setAttribute("aria-label", c.n);
        b.onclick = () => this.answer(b, c.n === target.n);
        wrap.appendChild(b);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) { btn.classList.add("correct"); sndGood(); say("Yes!");
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 700);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 4: Animal Sounds
     What the child practises: knowing animals and listening carefully
     ===================================================================== */
  const gSounds = {
    id: "sounds", title: "Animal Sounds", emoji: "🐮", color: "var(--c-green)", skill: "Animals",
    start() { this.run = makeRunner(5); this.round(); },
    round() {
      const choices = shuffle(ANIMAL_SOUNDS).slice(0, 4);
      const target = pick(choices);
      setPrompt(`Who says <b>“${target.s}”</b>? <small>Tap the animal</small>`);
      say("Who says " + target.s + "?");
      const s = stage();
      const wrap = el("div", "options cols-2");
      choices.forEach(c => {
        const b = el("button", "opt", `<span style="font-size:3rem">${c.e}</span>`);
        b.style.minHeight = "120px";
        b.setAttribute("aria-label", c.n);
        b.onclick = () => { if (c.n === target.n) say(c.s); this.answer(b, c.n === target.n); };
        wrap.appendChild(b);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) { btn.classList.add("correct"); sndGood();
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 900);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 5: Memory Match (finding pairs)
     What the child practises: short-term memory and staying focused
     ===================================================================== */
  const gMemory = {
    id: "memory", title: "Memory Match", emoji: "🧠", color: "var(--c-purple)", skill: "Memory",
    start() {
      setPrompt("Find the matching pairs! <small>Tap two cards</small>");
      say("Find the matching pairs");
      const picks = shuffle(ANIMALS).slice(0, 3);
      const deck = shuffle([...picks, ...picks]);
      this.first = null; this.lock = false; this.matched = 0;
      const s = stage();
      const grid = el("div", "options cols-3");
      grid.style.gap = "var(--space-3)";
      deck.forEach((a, i) => {
        const card = el("button", "opt", "❓");
        card.style.minHeight = "100px"; card.dataset.n = a.n; card.dataset.e = a.e; card.dataset.open = "0";
        card.onclick = () => this.flip(card);
        grid.appendChild(card);
      });
      s.appendChild(grid);
    },
    flip(card) {
      if (this.lock || card.dataset.open === "1") return;
      card.textContent = card.dataset.e; card.dataset.open = "1"; sndTap();
      if (!this.first) { this.first = card; return; }
      this.lock = true;
      if (this.first.dataset.n === card.dataset.n) {
        sndGood(); this.matched++; card.classList.add("correct"); this.first.classList.add("correct");
        this.first = null; this.lock = false;
        if (this.matched === 3) setTimeout(() => reward(3, "All matched!"), 500);
      } else {
        sndOops();
        const a = this.first, b = card;
        setTimeout(() => { a.textContent = "❓"; b.textContent = "❓"; a.dataset.open = "0"; b.dataset.open = "0"; this.first = null; this.lock = false; }, 850);
      }
    }
  };

  /* =====================================================================
     GAME 6: Letter Hunt
     What the child practises: recognising the letters of the alphabet
     ===================================================================== */
  const gABC = {
    id: "abc", title: "Letter Hunt", emoji: "🔤", color: "var(--c-orange)", skill: "Letters",
    start() { this.run = makeRunner(5); this.round(); },
    round() {
      const letters = shuffle("ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")).slice(0, 4);
      const target = pick(letters);
      setPrompt(`Find the letter <b>${target}</b> <small>Tap the right letter</small>`);
      say("Find the letter " + target);
      const s = stage();
      const wrap = el("div", "options cols-2");
      letters.forEach(L => {
        const b = el("button", "opt", L);
        b.style.color = pick(COLORS).hex; b.style.minHeight = "120px";
        b.onclick = () => this.answer(b, L === target);
        wrap.appendChild(b);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) { btn.classList.add("correct"); sndGood(); say(btn.textContent);
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 700);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 7: Big or Small
     What the child practises: comparing sizes
     ===================================================================== */
  const gSize = {
    id: "size", title: "Big or Small", emoji: "🐘", color: "var(--c-pink)", skill: "Sizes",
    start() { this.run = makeRunner(5); this.round(); },
    round() {
      const a = pick(ANIMALS);
      const wantBig = Math.random() < .5;
      setPrompt(`Tap the <b>${wantBig ? "BIG" : "small"}</b> ${a.n} <small>Look at the sizes</small>`);
      say("Tap the " + (wantBig ? "big" : "small") + " " + a.n);
      const s = stage();
      const wrap = el("div", "options cols-2");
      wrap.style.alignItems = "center";
      const sizes = shuffle([{ big: true, fs: "5.5rem" }, { big: false, fs: "2.4rem" }]);
      sizes.forEach(sz => {
        const b = el("button", "opt", `<span style="font-size:${sz.fs}">${a.e}</span>`);
        b.style.minHeight = "150px";
        b.onclick = () => this.answer(b, sz.big === wantBig);
        wrap.appendChild(b);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) { btn.classList.add("correct"); sndGood(); say("Yes!");
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 700);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 8: What Comes Next? (patterns and sequencing)
     What the child practises: spotting and finishing a simple AB pattern
     ===================================================================== */
  const gPattern = {
    id: "pattern", title: "What Comes Next?", emoji: "🔁", color: "var(--c-yellow)", skill: "Patterns",
    start() { this.run = makeRunner(5); this.round(); },
    round() {
      const two = shuffle(["🍎", "🍌", "🍇", "🍊", "🍓", "🫐", "🍐"]).slice(0, 2);
      const [a, b] = two;
      const seq = [a, b, a, b, a]; // the missing one should be b
      const answer = b;
      setPrompt(`What comes next? <small>Finish the pattern</small>`);
      say("What comes next?");
      const s = stage();
      const row = el("div", "center");
      row.style.fontSize = "clamp(2rem,10vw,3rem)";
      row.style.marginBottom = "var(--space-6)";
      row.innerHTML = seq.join(" ") + ' <span style="opacity:.4">▢</span>';
      s.appendChild(row);
      const opts = shuffle([answer, a, pick(["🍉", "🥝", "🍒"])]);
      const wrap = el("div", "options cols-3");
      opts.forEach(o => {
        const btn = el("button", "opt", `<span style="font-size:3rem">${o}</span>`);
        btn.onclick = () => this.answer(btn, o === answer);
        wrap.appendChild(btn);
      });
      s.appendChild(wrap);
    },
    answer(btn, correct) {
      if (correct) { btn.classList.add("correct"); sndGood(); say("Yes!");
        setTimeout(() => this.run.next() ? this.run.finish() : this.round(), 700);
      } else { btn.classList.add("wrong"); sndOops(); setTimeout(() => btn.classList.remove("wrong"), 500); }
    }
  };

  /* =====================================================================
     GAME 9: Pop the Bubbles (tap to clear them all)
     What the child practises: hand–eye coordination and one-by-one counting
     ===================================================================== */
  const gBubbles = {
    id: "bubbles", title: "Pop the Bubbles", emoji: "🫧", color: "var(--c-teal)", skill: "Tap & Pop",
    start() {
      this.left = 8;
      setPrompt(`Pop all the bubbles! <small><span id="bubLeft">${this.left}</span> left</small>`);
      say("Pop all the bubbles");
      const s = stage();
      s.style.position = "relative"; s.style.height = "380px"; s.style.overflow = "hidden";
      this.s = s;
      for (let i = 0; i < this.left; i++) this.spawn();
    },
    spawn() {
      const s = this.s;
      const b = el("button", null, "");
      const size = 64 + rand(36);
      b.style.cssText = `position:absolute;width:${size}px;height:${size}px;border-radius:50%;
        background:radial-gradient(circle at 30% 30%, #fff, ${pick(COLORS).hex});
        box-shadow:0 4px 0 rgba(0,0,0,.12);`;
      b.style.left = rand(Math.max(10, s.clientWidth - size - 10)) + "px";
      b.style.top = rand(Math.max(10, s.clientHeight - size - 10)) + "px";
      b.setAttribute("aria-label", "bubble");
      b.onclick = () => {
        sndTap(); beep(400 + rand(500), .08, "sine", .12);
        b.style.transform = "scale(1.4)"; b.style.opacity = "0"; b.style.transition = "all .18s ease";
        setTimeout(() => b.remove(), 180);
        this.left--; const lc = $("#bubLeft"); if (lc) lc.textContent = this.left;
        if (this.left <= 0) setTimeout(() => reward(3, "All popped!"), 250);
      };
      s.appendChild(b);
    }
  };

  /* =====================================================================
     GAME 10: Finger Painting (free drawing)
     What the child practises: being creative and steadying small fingers
     ===================================================================== */
  const gDraw = {
    id: "draw", title: "Finger Painting", emoji: "🖍️", color: "var(--c-red)", skill: "Creativity",
    start() {
      setPrompt(`Draw anything you like! <small>Pick a colour and use your finger</small>`);
      say("Draw anything you like");
      const s = stage();
      const palette = el("div");
      palette.style.cssText = "display:flex;gap:8px;flex-wrap:wrap;justify-content:center;margin-bottom:14px;";
      this.color = COLORS[0].hex; this.sizePx = 14;
      COLORS.forEach((c, i) => {
        const sw = el("button");
        sw.style.cssText = `width:52px;height:52px;border-radius:50%;background:${c.hex};box-shadow:0 4px 0 rgba(0,0,0,.12);border:4px solid ${i === 0 ? "#2b2440" : "transparent"}`;
        sw.setAttribute("aria-label", c.name);
        sw.onclick = () => { this.color = c.hex; sndTap(); $$("button", palette).forEach(x => x.style.borderColor = "transparent"); sw.style.borderColor = "#2b2440"; };
        palette.appendChild(sw);
      });
      s.appendChild(palette);

      const wrap = el("div", "canvas-wrap");
      const cv = el("canvas", "draw");
      const W = Math.min(s.clientWidth - 40, 520);
      cv.width = W; cv.height = 300; cv.style.width = W + "px"; cv.style.height = "300px";
      wrap.appendChild(cv); s.appendChild(wrap);

      const tools = el("div", "center mt");
      const clr = el("button", "btn-big", "🧽 Clear"); clr.style.background = "var(--c-blue)";
      const done = el("button", "btn-big", "✅ I'm done!"); done.style.marginLeft = "10px";
      tools.appendChild(clr); tools.appendChild(done); s.appendChild(tools);

      const ctx = cv.getContext("2d");
      ctx.lineCap = "round"; ctx.lineJoin = "round";
      let drawing = false, last = null;
      const pos = (ev) => { const r = cv.getBoundingClientRect(); const p = ev.touches ? ev.touches[0] : ev; return { x: (p.clientX - r.left) * (cv.width / r.width), y: (p.clientY - r.top) * (cv.height / r.height) }; };
      const startD = (e) => { e.preventDefault(); drawing = true; last = pos(e); dot(last); };
      const moveD = (e) => { if (!drawing) return; e.preventDefault(); const p = pos(e); ctx.strokeStyle = this.color; ctx.lineWidth = this.sizePx; ctx.beginPath(); ctx.moveTo(last.x, last.y); ctx.lineTo(p.x, p.y); ctx.stroke(); last = p; };
      const endD = () => { drawing = false; };
      const dot = (p) => { ctx.fillStyle = this.color; ctx.beginPath(); ctx.arc(p.x, p.y, this.sizePx / 2, 0, 7); ctx.fill(); };
      cv.addEventListener("mousedown", startD); cv.addEventListener("mousemove", moveD); window.addEventListener("mouseup", endD);
      cv.addEventListener("touchstart", startD, { passive: false }); cv.addEventListener("touchmove", moveD, { passive: false }); cv.addEventListener("touchend", endD);
      clr.onclick = () => { ctx.clearRect(0, 0, cv.width, cv.height); sndTap(); };
      done.onclick = () => reward(2, "Beautiful art!");
    }
  };

  /* =====================================================================
     Put every game into the list and lay out the home screen tiles
     ===================================================================== */
  const GAMES = [gColor, gCount, gShape, gSounds, gMemory, gABC, gSize, gPattern, gBubbles, gDraw];

  function buildHome() {
    const grid = $("#gameGrid");
    grid.innerHTML = "";
    GAMES.forEach(g => {
      const card = el("button", "game-card");
      card.style.background = `linear-gradient(150deg, ${g.color}, color-mix(in srgb, ${g.color} 70%, #000 12%))`;
      card.innerHTML = `<span class="badge">${g.skill}</span>
        <span class="emoji">${g.emoji}</span>
        <span class="name">${g.title}</span>`;
      card.onclick = () => { sndTap(); openGame(g); };
      grid.appendChild(card);
    });
  }

  /* ---------- hook up all the buttons and start things off ---------- */
  function init() {
    buildHome();
    $("#starNum").textContent = stars;
    $$("[data-home]").forEach(b => b.onclick = goHome);
    $("#replayBtn").onclick = () => { if (currentGame) { hideReward(); currentGame.start(); } };
    $("#rewardNext").onclick = () => { hideReward(); if (currentGame) currentGame.start(); };
    $("#openParent").onclick = () => show("screen-parent");
    $("#resetStars").onclick = () => { stars = 0; $("#starNum").textContent = 0; sndTap(); };
    const st = $("#soundToggle");
    st.onclick = () => { soundOn = !soundOn; document.body.classList.toggle("muted", !soundOn); if (soundOn) sndTap(); else window.speechSynthesis && window.speechSynthesis.cancel(); };
    // phones only allow sound after the first tap, so wake the audio up then
    const unlock = () => { ac(); if (actx && actx.state === "suspended") actx.resume(); window.removeEventListener("touchstart", unlock); window.removeEventListener("click", unlock); };
    window.addEventListener("touchstart", unlock); window.addEventListener("click", unlock);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
