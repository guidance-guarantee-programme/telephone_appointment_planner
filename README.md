# README

# Getting started

```bash
./bin/setup
```

# How to run the test suite

```bash
bundle exec rake
```

# Deployment instructions

## Staging

```bash
# Add the heroku remote
heroku git:remote -a staging-tap-pensionwise -r staging

# Deploy
git push staging master
```
