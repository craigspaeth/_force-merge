# force-merge

This is a quick working prototype of what it would be like to merge [Force](https://github.com/artsy/force) and [Microgravity](https://github.com/artsy/microgravity) into one codebase. As you can see we have two folders, /desktop and /mobile which are slightly modified versions of the Force and MG codebases. These then get mounted in the root index.js file which checks the user agent and determine whether it should route to either app.

## Get started

```
brew install nvm
nvm install 6
nvm alias default 6
touch .env # Find the force-merge.env secure note in 1Password
npm i
npm start
```

# Deploying to staging/production

- Set `APP_URL` `ARTSY_URL` `MOBILE_URL` to (staging.)artsy.net
- Set `CDN_URL` to the right place
- Set `COMMIT_HASH` to the latest short commit (done in bucket assets)
- Set all of the `FAKE123123123` keys to real things

## TODO

- Create a merged S3 bucket that deploys assets to the same place, and copies everything else from Force production & MG production to the same place
- Refactor mobile redirect code
- Set up tests with CircleCI
- Set up deployment with Heroku pipelines (figure out asset story)
- Add Danger/CONTRIBUTING/etc. back in
