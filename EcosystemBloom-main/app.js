const app = document.getElementById('app');

let profile = null;
let garden = [];
let xp = 0;
let seeds = 0;

const plants = [
  {name:"River Red Gum", info:"Protect riverbanks. Water first year."},
  {name:"Yellow Box", info:"Open woodland tree. Mulch base."},
  {name:"Silver Wattle", info:"Fast shelter. Thin after 3-4 yrs."},
  {name:"Kangaroo Grass", info:"Feed small birds. Low-water once established."},
  {name:"Chocolate Lily", info:"Flowers smell like chocolate. Dormant in summer."},
  {name:"River Bottlebrush", info:"Supports nectar feeders. Light prune after flowering."}
];

function showOnboarding() {
  app.innerHTML = `
    <div class="page">
      <h2>Welcome to Ecosystem Bloom</h2>
      <input id="name" placeholder="Your Name"/>
      <input id="state" placeholder="State / Town"/>
      <input id="age" placeholder="Age"/>
      <button id="startBtn">Start</button>
    </div>
  `;
  document.getElementById('startBtn').onclick = () => {
    profile = {
      name: document.getElementById('name').value,
      school: document.getElementById('state').value,
      age: document.getElementById('age').value
    };
    showScan();
  }
}

function showScan() {
  app.innerHTML = `
    <div class="page">
      <h2>Scan Plants by File Name</h2>
      <input type="file" id="fileInput" multiple />
      <div id="scanResults" class="scan-results"></div>
      <div class="navbar">
        <button class="active" id="navScan">Scan</button>
        <button id="navGarden">Garden</button>
        <button id="navQuests">Quests</button>
      </div>
    </div>
  `;

  document.getElementById('fileInput').onchange = handleFiles;
  document.getElementById('navGarden').onclick = showGarden;
  document.getElementById('navQuests').onclick = showQuests;
  document.getElementById('navScan').onclick = showScan;
}

function handleFiles(event) {
  const files = Array.from(event.target.files);
  files.forEach(file => {
    // Remove file extension and decode spaces
    const name = file.name.replace(/\.[^/.]+$/, "").replace(/_/g, " ").replace(/%20/g, " ").trim();
    const plant = plants.find(p => p.name.toLowerCase() === name.toLowerCase());
    if (plant) addScanResult(plant);
    else addScanResult({name: name, info: "No info available."});
  });
}

function addScanResult(plant) {
  const container = document.getElementById("scanResults");
  const div = document.createElement("div");
  div.classList.add("scan-card");
  div.innerHTML = `
    <div>
      <h3>${plant.name}</h3>
      <p>${plant.info}</p>
      <button onclick="addPlant('${plant.name}')">Add to Garden</button>
    </div>
  `;
  container.appendChild(div);
}

function addPlant(name) {
  const plant = plants.find(p => p.name === name) || {name: name, info: "No info available."};
  garden.push(plant);
  seeds += 1;
  xp += 15;
  updateGardenUI();
}

function updateGardenUI() {
  if (!document.getElementById("garden")) {
    showGarden();
    return;
  }
  const container = document.getElementById("garden");
  container.innerHTML = "";
  garden.forEach(p => {
    const div = document.createElement("div");
    div.className = "garden-plant";
    div.innerHTML = `<div>${p.name}</div><div class="info">${p.info}</div>`;
    container.appendChild(div);
  });
}

function showGarden() {
  app.innerHTML = `
    <div class="page">
      <h2>Your Garden</h2>
      <p style="text-align:center; font-weight:bold;">
        XP: ${xp} | Seeds: ${seeds} (¢${seeds*5})
      </p>
      <div id="garden" class="garden-grid"></div>
      <div class="navbar">
        <button id="navScan">Scan</button>
        <button class="active" id="navGarden">Garden</button>
        <button id="navQuests">Quests</button>
      </div>
    </div>
  `;
  updateGardenUI();
  document.getElementById('navScan').onclick = showScan;
  document.getElementById('navQuests').onclick = showQuests;
  document.getElementById('navGarden').onclick = showGarden;
}

function showQuests() {
  app.innerHTML = `
    <div class="page">
      <h2>Quests</h2>
      <ul style="line-height:1.6;">
        <li>Daily: Snap a native tree (+25 XP)</li>
        <li>Daily: Log a flowering plant (+25 XP)</li>
        <li>Weekly: Teach a friend one conservation tip (+100 XP)</li>
      </ul>
      <div class="navbar">
        <button id="navScan">Scan</button>
        <button id="navGarden">Garden</button>
        <button class="active" id="navQuests">Quests</button>
      </div>
    </div>
  `;
  document.getElementById('navScan').onclick = showScan;
  document.getElementById('navQuests').onclick = showQuests;
  document.getElementById('navGarden').onclick = showGarden;
}

showOnboarding();
