require! {
  fs
  levn
  'mongo-uri'
}
{exec} = require 'shelljs'

# usage:

datecmd = 'date'
if fs.existsSync('/usr/local/bin/gdate')
  datecmd = '/usr/local/bin/gdate'

curdate = exec(datecmd + ' --rfc-3339=seconds').stdout.split(' ').join('_').trim()

dumpdir = ['mongo', curdate].join('_')

mongourl = process.argv[2]
if not mongourl?
  console.log 'must provide mongo url'
  process.exit()

console.log 'mongourl: ' + mongourl

if mongourl.indexOf('mongodb://') != 0
  console.log 'mongourl does not begin with mongodb://'
  process.exit()

listcollections = (uri) ->
  login = mongo-uri.parse uri
  host = login['hosts'][0] + ':' + login['ports'][0]
  db = login['database']
  user = login['username']
  passwd = login['password']
  return levn.parse '[String]', exec("mongo --username #{user} --password #{passwd} #{host + '/' + db} --eval 'db.getCollectionNames()'").stdout.trim().split('\n').filter((x) -> x.indexOf('MongoDB shell version') == -1 && x.indexOf('connecting to:') == -1).join('\n')

console.log 'collections:'
all_collections = listcollections(mongourl)
console.log all_collections

if all_collections.length == 0
  console.log 'no collections to dump'
  process.exit()

mkexport = (uri, collection) ->
  #login = json.loads(check_output("lsc parse_mongo_uri.ls '" + uri + "'", shell=True))
  login = mongo-uri.parse uri
  host = login['hosts'][0] + ':' + login['ports'][0]
  db = login['database']
  user = login['username']
  passwd = login['password']
  #exec('mongoexport -h ' + host + ' -d ' + db + ' -u ' + user + ' -p ' + passwd + " -c " + collection + " -o '" + outfile + "'")
  exec('mongodump -h ' + host + ' -d ' + db + ' -u ' + user + ' -p ' + passwd + " -c " + collection + " -o '" + dumpdir + "'")

for collection in all_collections
  mkexport mongourl, collection