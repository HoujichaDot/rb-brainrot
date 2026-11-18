// Brainrot Bonanza: a 3D Roblox brainrot game (Node 22, standard library only). The game is this
// directory's Rojo project, built into game.rbxl with `rojo build default.project.json --output game.rbxl`;
// this program then hands it in. It copies game.rbxl, src/, screenshots/ and PLAY.json from beside this
// file to /output and writes /output/dossier.json, the summary the judge reads, with the vendored make.fun
// library. The place itself is assembled at runtime from parts: 21 part-built brainrots, four plots, a
// shop row, stealing with shields, a tsunami hazard and rebirths. screenshots/ holds the entry captures
// (the first by name is the cover), and PLAY.json names the published experience.
//
// Every name under /output starts with a letter, a digit or _ and holds only letters, digits, . _ and -: the
// grader fails an entry whose output holds any other, so a file such as .gitkeep or .DS_Store copied in fails it.
// So src/ and screenshots/ are copied without any name that starts with a dot, at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Guard: a PLAY.json that still names the starter's place id 0 must never be handed in.
const play = JSON.parse(readFileSync(join(here, 'PLAY.json'), 'utf8')) as { place_id?: number };
if (!play.place_id || play.place_id === 0) {
  throw new Error(`PLAY.json names place_id ${String(play.place_id)} — write the published experience's ids into PLAY.json first.`);
}
console.log(`[makefun] staging entry from ${here} into ${out}`);

/** cpSync's filter: leave out every file and directory whose name starts with a dot (.gitkeep, .DS_Store, .git). */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);

// Log the dossier's Place block so the hand-in is easy to eyeball.
const dossier = JSON.parse(readFileSync(join(out, 'dossier.json'), 'utf8')) as { text?: string };
const placeBlock = (dossier.text ?? '').split('## Scripts')[0] ?? '';
for (const line of placeBlock.trim().split('\n')) console.log(`[makefun] ${line}`);

// Hand-in guard: every item the grader opens must actually be in the output.
for (const name of ['game.rbxl', 'PLAY.json', 'dossier.json', 'src', 'screenshots']) {
  if (!existsSync(join(out, name))) throw new Error(`staged output is missing ${name}: ${out}`);
}
console.log(`[makefun] staged game.rbxl, PLAY.json, src/, screenshots/ and dossier.json in ${out}`);
