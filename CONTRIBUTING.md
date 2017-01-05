# Contributing to Force

This project is work of [many developers](https://github.com/artsy/force/graphs/contributors).

We accept [pull requests](https://github.com/artsy/force/pulls), and you may [propose features and discuss issues](https://github.com/artsy/force/issues).

In the examples below, substitute your GitHub username for `contributor` in URLs.

## Fork the Project

Fork the [project on GitHub](https://github.com/artsy/force) and check out your copy.

```
git clone https://github.com/contributor/force.git
cd force
git remote add upstream https://github.com/artsy/force.git
```

## Run Force

Install [NVM](https://github.com/creationix/nvm) and Node 5.

```sh
nvm install 5
nvm alias default 5
```

Install node modules.

```
npm install
```

Artsy developers should create a `.env` file and paste in the sensitive configuration from 1Password, under _force.env_. Ask for help in the `#web` Slack channel if you need access to that.

Open-source contributors do not need to manually create a `.env` file.

Start Force pointing to the staging Artsy API (Gravity).

```sh
# For Artsy Staff
make ss

# For OSS participants
make oss
```

Force should now be running at [http://localhost:5000/](http://localhost:5000/).

## Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

## Write Tests

Write tests for all new features and fixes. Run tests with `npm test`.

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

## Write Code

Implement your feature or bug fix.

## Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

## Push

```
git push origin my-feature-branch
```

## Make a Pull Request

Go to https://github.com/contributor/force and select your feature branch.
Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

## Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

## Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster with Semaphore. Everything should look green, otherwise fix issues and amend your commit as described above.

## Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really. <3
