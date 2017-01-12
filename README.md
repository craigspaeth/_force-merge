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

## TODO

- Refactor mobile redirect code
- Set up tests with CircleCI
- Set up staging/production deployment
- Add Danger/CONTRIBUTING/etc. back in
