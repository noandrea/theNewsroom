# The Newsroom

~~it is to complicated to know the world.~~

A better way to understand what's going on.


# Dev setup

- start the database
`docker-compose up -d`
- load the schema
`docker exec -i newsroom_db psql -U newsroom newsroom < schema.sql`
- load data
`docker exec -i newsroom_db psql -U newsroom newsroom < countries.sql`


## from dev to prod

to move to a production environment (without using the bundled docker-compose )
here are the action to step to follow:

> Note: the following assumes that the user/pass for the new postres role is newsroom/newsroom

1. backup your dev database
```
make docker-backup
backup docker database
docker exec -i newsroom_db pg_dump -U newsroom --clean --create --if-exists --no-owner --no-acl newsroom > thenewsroom-XXXXXXX_XXXX.dump.sql
done
```

2. create a new role
```
$ sudo -u postgres psql
postgres=# create role newsroom with login createdb encrypted password 'newsroom';
CREATE ROLE
postgres=# \q
```

3. import the backup database

> **THIS OPERATION WILL OVERWRITE YOUR EXISTING DATABASE PROCEED WITH CAUTION**

```
psql -U newsroom -h 127.0.0.1 -W template1 < thenewsroom-XXXXXXX_XXXX.dump.sql
```

4. install python dependencies
```
$ pip install -r requirements.txt 
```

5. set a cron job to execute the commands
```
0 */6 * * * theNewsroowmProduction.sh
```

