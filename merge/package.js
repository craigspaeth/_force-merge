const merge = require('package-merge')
const fs = require('fs')
const path = require('path')

const basePackage = {
  "name": "force-merge",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "engines": {
    "node": "6.x.x",
    "npm": "4.x.x"
  },
  "babel": {
    "presets": [
      "es2015",
      "stage-3"
    ],
    "plugins": [
      "transform-runtime"
    ]
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "merge": "sh merge/main.sh",
    "start": "npm run merge && node  -r dotenv/config .",
    "push": "npm run merge && git add . && git commit -a -m 'deploying' && git push --force git@heroku.com:force-merge.git",
    "deploy-assets": "ezel-assets && manifest=`bucket-assets --manifest-to-stdout true --bucket force-merge-staging` && heroku config:set ASSET_MANIFEST=$manifest"
    "deploy": "npm run deploy-assets && git push --force git@heroku.com:force-merge-staging.git"
  },
  "license": "MIT",
}

const a = fs.readFileSync(path.resolve(__dirname, '../mobile/package.json'))
const b = fs.readFileSync(path.resolve(__dirname, '../desktop/package.json'))
const mergedPackage = Object.assign(JSON.parse(merge(a, b)), basePackage)

const fld = path.resolve(__dirname, '../package.json')
fs.writeFileSync(fld, JSON.stringify(mergedPackage, null, 2))
