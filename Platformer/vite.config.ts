import path from "node:path";
import { defineConfig } from "vite";

const julgameRoot = path.resolve(__dirname, "../../JulGame.jl/ts");

export default defineConfig({
    base: "./",
    root: ".",
    assetsInclude: ["**/*.wasm"],
    resolve: {
        alias: {
            julgame: julgameRoot,
        },
    },
    server: {
        port: 5174,
        fs: {
            allow: [julgameRoot, path.resolve(__dirname, ".."), path.resolve(__dirname, "../..")],
        },
    },
    optimizeDeps: {
        exclude: ["julgame/src/platform/sdl-wasm/julgame.js"],
    },
});
