//
// Copies over files from the Force & Microgravity S3 buckets into a new bucket
//
const s3 = require('s3')

const {
  S3_KEY,
  S3_SECRET,
  S3_BUCKET,
  OLD_S3_KEY,
  OLD_S3_SECRET
} = process.env

const folders = [
  'video',
  'sounds',
  'pdf',
  'json',
  'javascripts',
  'institution-partnerships',
  'images',
  'icons',
  'gallery-partnerships',
  'fonts',
  'data',
  'auction-partnerships',
  'about'
]

const old = s3.createClient({
  s3Options: {
    accessKeyId: OLD_S3_KEY,
    secretAccessKey: OLD_S3_SECRET
  }
})

const merged = s3.createClient({
  s3Options: {
    accessKeyId: S3_KEY,
    secretAccessKey: S3_SECRET
  }
})

const pdf = old.downloadDir({
  localDir: 'tmp',
  s3Params: {
    Prefix: 'pdf',
    Bucket: 'force-staging'
  }
})
pdf.on('progress', () => console.log('...', pdf.progressAmount))
pdf.on('end', () => console.log('done'))
