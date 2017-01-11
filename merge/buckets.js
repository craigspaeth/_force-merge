//
// Copies over files from the Force & Microgravity S3 buckets into a new bucket
//
const knox = require('knox')
const {
  S3_KEY,
  S3_SECRET,
  S3_BUCKET,
  OLD_S3_KEY,
  OLD_S3_SECRET
} = process.env

const force = knox.createClient({
  key: OLD_S3_KEY,
  secret: OLD_S3_SECRET,
  bucket: 'force-production'
})

const microgravity = knox.createClient({
  key: OLD_S3_KEY,
  secret: OLD_S3_SECRET,
  bucket: 'microgravity-production'
})

const merged = knox.createClient({
  key: S3_KEY,
  secret: S3_BUCKET,
  bucket: S3_BUCKET
})
