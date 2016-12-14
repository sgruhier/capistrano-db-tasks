# Capistrano-db-tasks Changelog

Reverse Chronological Order:

## master

https://github.com/sgruhier/capistrano-db-tasks/compare/v0.6...HEAD

* Your contribution here!

# 0.6 (Dec 14 2016)

* Configurable dump folder #101 #75 #61 (@artempartos, @gmhawash)
* Fixed previous release bugs (@sitnikovme, @slavajacobson)

# 0.5 (Nov 29 2016)

* Fixed iteration on remote/local assets dir #98 (@elthariel)
* Fetch :user property on server #97 (@elthariel)
* Add support of ENV['DATABASE_URL'] #54 #70 #99 (@numbata, @fabn, @donbobka, @ktaragorn, @markgandolfo, @leifcr, @elthariel)
* Specify database for pg\_terminate_backend #93 (@stevenchanin)
* Show local execution failure log #89 (@dtaniwaki)
* Add postigs to allowed PG adapters #91 (@matfiz)
* Added database name to --ignore-table statements for MySQL #76 (@km-digitalpatrioten)
* Add :db\_ignore\_tables option #65 (@rdeshpande)
* Update README.markdown #67 (@alexbrinkman)
* Using gzip instead of bzip2 (configurable) #48 #59 (@numbata)

# 0.4 (Feb 26 2015)

https://github.com/sgruhier/capistrano-db-tasks/compare/v0.3...v0.4

* Set correct username for pg connection #55 (@numbata)
* Protect remote server from pushing #51 (@IntractableQuery)
* Use stage name as rails\_env #49 (@bronislav)
* Remove local db dump after db:push if db_local_clean is set #47 (@pugetive)
* Fixed app:pull and app:push tasks #42 (@iamdeuterium)
* Added space between -p and the password #41 (@iamdeuterium)
* Add option to skip data synchronization prompt question #37 (@rafaelsales)
* Add option to remove remote dump file after downloading to local #36 (@rafaelsales)
* Use port option from database.yml #35 (@numbata)
* Use heroku dump/restore arguments for postgresql #26 (@mdpatrick)

# 0.3 (Feb 9 2014)

https://github.com/sgruhier/capistrano-db-tasks/compare/v0.2.1...v0.3

* Capistrano 3 support PR #23 (@sauliusgrigaitis)
