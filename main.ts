import { copyFileSync, cpSync, existsSync, mkdirSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const REQUIRED_SHOTS = [
  '1-cover-world.jpg',
  '2-heist-whack.jpg',
  '3-stamp-book.jpg',
  '4-runaway-locomotive.jpg',
];

const botDir = process.env.MAKEFUN_BOT_DIR || fileURLToPath(new URL('.', import.meta.url));
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const notDotted = (entryPath: string): boolean => !basename(entryPath).startsWith('.');

mkdirSync(outDir, { recursive: true });
copyFileSync(join(botDir, 'game.rbxl'), join(outDir, 'game.rbxl'));
copyFileSync(join(botDir, 'PLAY.json'), join(outDir, 'PLAY.json'));
cpSync(join(botDir, 'src'), join(outDir, 'src'), { recursive: true, filter: notDotted });

const outShots = join(outDir, 'screenshots');
mkdirSync(outShots, { recursive: true });
if (existsSync(join(botDir, 'screenshots'))) {
  cpSync(join(botDir, 'screenshots'), outShots, { recursive: true, filter: notDotted });
}

for (const shot of REQUIRED_SHOTS) {
  const shotPath = join(outShots, shot);
  if (!existsSync(shotPath)) {
    throw new Error(`Missing required showcase screenshot: ${shotPath}`);
  }
  const { size } = statSync(shotPath);
  if (size <= 0 || size > 262144) {
    throw new Error(`Invalid screenshot size (${size} bytes) for ${shot}`);
  }
}

const dossierBytes = buildDossier(outDir, {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
});

writeFileSync(join(outDir, 'dossier.json'), dossierBytes);
