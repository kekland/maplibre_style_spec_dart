#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const keys = require('./keys').default;
const { exec } = require('child_process');

const createMaptilerMaps = (apiKey) => {
  const maps = [
    'aquarelle',
    'backdrop',
    'basic-v2',
    'bright-v2',
    'dataviz',
    'landscape',
    'ocean',
    'openstreetmap',
    'outdoor-v2',
    'satellite',
    'streets-v2',
    'toner-v2',
    'topo-v2',
    'winter-v2',
    'jp-mierune-dark',
    'jp-mierune-gray',
    'jp-mierune-streets',
    'nl-cartiqo-dark',
    'nl-cartiqo-light',
    'nl-cartiqo-topo',
    'cadastre',
    'cadastre-satellite',
    'ch-swisstopo-lbm',
    'ch-swisstopo-lbm-dark',
    'ch-swisstopo-lbm-grey',
    'ch-swisstopo-lbm-vivid',
    'uk-openzoomstack-light',
    'uk-openzoomstack-night',
    'uk-openzoomstack-outdoor',
    'uk-openzoomstack-road',
  ];

  return maps.map(name => ({
    name: `maptiler-${name}`,
    url: `https://api.maptiler.com/maps/${name}/style.json?key=${apiKey}`
  }));
}
(async () => {
  const maps = [];

  if (keys.maptilerKey) {
    console.log('Adding MapTiler maps...');
    maps.push(...createMaptilerMaps(keys.maptilerKey));
  }

  console.log(`Generating ${maps.length} map files...`);

  const fixturesPath = path.join(__dirname, '..', 'test', 'fixtures');

  if (fs.existsSync(fixturesPath)) {
    fs.rmSync(fixturesPath, { recursive: true });
  }

  fs.mkdirSync(fixturesPath);

  for (const map of maps) {
    const filePath = path.join(fixturesPath, `${map.name}.json`);
    const data = await fetch(map.url);

    if (data.status !== 200) {
      console.error(`Failed to fetch ${map.name}`);
    }
    else {
      fs.writeFileSync(filePath, JSON.stringify(await data.json(), null, 2));
      console.log(`Wrote ${filePath}`);
    }
  }

  for (const file of fs.readdirSync(fixturesPath)) {
    if (!file.endsWith('.json')) continue;

    // Perform gl-style-migrate on each file and replace the original
    const filePath = path.join(fixturesPath, file);
    
    // Move the original file to {name}-original.json
    const originalPath = filePath.replace('.json', '-original.json');
    fs.renameSync(filePath, originalPath);

    exec(`gl-style-migrate ${originalPath} > ${filePath}`, (err, stdout, stderr) => {
      if (err) {
        console.error(`Failed to migrate ${filePath}`);
        console.error(stderr);
      }
      else {
        console.log(`Migrated ${filePath}`);
      }
    });
  }
})()