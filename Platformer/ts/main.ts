import "julgame/src/engine/core/globalConstants";
import { SDLPlatform, type ProjectConfig } from "julgame/src/platform/sdl-wasm";

/** Side-effect imports register transpiled game scripts (`npm run transpile`). */
import "./_generated/scripts/index";

function getRequiredElement<T extends Element>(id: string, ctor: { new (): T }): T {
    const el = document.getElementById(id);
    if (!(el instanceof ctor)) {
        throw new Error(`Missing #${id}`);
    }
    return el;
}

/** Resolve from the served page (Platformer `index.html`), not the julgame engine package path. */
const pageRoot = new URL("./", window.location.href);
const project: ProjectConfig = {
    sceneJsonUrl: new URL("scenes/scene.json", pageRoot).href,
    memfsAssetBaseUrl: pageRoot.href,
    basePath: "/game",
};

async function boot(): Promise<void> {
    const canvas = getRequiredElement("canvas", HTMLCanvasElement);
    const status = getRequiredElement("status", HTMLElement);
    const platform = new SDLPlatform(canvas, status, project);
    await platform.init();
}

boot().catch((err: unknown) => {
    console.error(err);
    const status = document.getElementById("status");
    if (status) {
        status.textContent = `Boot failed: ${String(err)}`;
    }
});
