# The Newsroom

~~it is to complicated to know the world.~~

A better way to understand what's going on.


# Setup

- start the database
`docker-compose up -d`
- load the schema
`docker exec -i newsroom_db psql -U newsroom newsroom < schema.sq`l
- load data
`docker exec -i newsroom_db psql -U newsroom newsroom < countries.sq`l

