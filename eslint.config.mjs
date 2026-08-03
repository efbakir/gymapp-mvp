import { FlatCompat } from "@eslint/eslintrc"
import { fileURLToPath } from "node:url"
import path from "node:path"

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)
const compat = new FlatCompat({ baseDirectory: dirname })

const config = [
  {
    ignores: [
      ".agents/**",
      ".claude/**",
      ".codex/**",
      ".cursor/**",
      ".next/**",
      "node_modules/**",
      "next-env.d.ts",
    ],
  },
  {
    linterOptions: {
      reportUnusedDisableDirectives: "off",
    },
  },
  ...compat.extends("next/core-web-vitals", "next/typescript"),
]

export default config
