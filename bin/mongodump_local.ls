require! {
  fs
  'mongo-uri'
}
{run, exec} = require 'execSync'

# usage:

datecmd = 'date'
if fs.existsSync('/usr/local/bin/gdate')
  datecmd = '/usr/local/bin/gdate'

curdate = exec(datecmd + ' --rfc-3339=seconds').stdout.split(' ').join('_').trim()

mongourl = 'mongodb://localhost:27017'
meteorsite = meteorsitebase = 'local'

console.log 'mongourl: ' + mongourl

listcollections = (uri) ->
  login = mongo-uri.parse uri
  host = login['hosts'][0] + ':' + login['ports'][0]
  return exec("mongo #{host} --eval 'db.getCollectionNames()'").stdout.trim().split('\n').filter((x) -> x.indexOf('MongoDB shell version') == -1 && x.indexOf('connecting to:') == -1).join('\n').split(',')

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
  #run('mongoexport -h ' + host + ' -d ' + db + ' -u ' + user + ' -p ' + passwd + " -c " + collection + " -o '" + outfile + "'")
  run('mongodump -h ' + host + " -c " + collection + " -o '" + dumpdir + "'")

for collection in all_collections
  mkexport mongourl, collection