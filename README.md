# Test WG Forge (Backend) (wargaming.net)

# Elixir

Prepare the environment. 

Run:
```
docker run -p 5432:5432 -e POSTGRES_USER=gst -e POSTGRES_PASSWORD=gst -d shelipov/gst:latest
```

Then inside the container will start a Postgresql server, and it will be accessible from the outside on port 5432. 
```
host: localhost
port: 5432
dbname: gst_db
username: gst
password: gst
```

Execute:
```
git clone https://github.com/Sh-el/wg_b.git
```
Then:
```
cd wg_b
```

Install the project dependencies using the command:
```
mix deps.get
```
Launch the application using the command: 
```
mix phx.server
```
Run: 
```
iex -S mix
```


# 1st task

In the database there is a table **cats** with such a scheme:
```
Table "public.cats"
     Column      |       Type
-----------------+-------------------
 name            | character varying
 color           | cat_color
 tail_length     | integer
 whiskers_length | integer
```

And it is filled with some data, like:
```
 name  |     color     | tail_length | whiskers_length
-------+---------------+-------------+-----------------
 Tihon | red & white   |          15 |              12
 Marfa | black & white |          13 |              11
```

About cats we all know some important information, such as name, color, length of tail and whiskers.

Color cats defined as an enumerated data type:
```
CREATE TYPE cat_color AS ENUM (
    'black',
    'white',
    'black & white',
    'red',
    'red & white',
    'red & black & white'
);
```

We need to find out how many cats of each color there are in the database and write this information to the table **cat_colors_info**:
```
Table "public.cat_colors_info"
 Column |   Type
--------+-----------
 color  | cat_color
 count  | integer
Indexes:
    "cat_colors_info_color_key" UNIQUE CONSTRAINT, btree (color)
```

It will look like this:
```
        color        | count
---------------------+-------
 black & white       |    1
 red & white         |    1
```

**Implementation in the module Wg.Animals.Cats, function count_cats_by_color.**

```
Wg.Animals.Cats.count_cats_by_color
```


# 2-е задание

We continue the analysis of our cats.

Need to calculate some statistics about cats:
- the average length of the tail,
- the median length tails
- fashion of the lengths of the tails
- the average length of the mustache,
- median lengths of whiskers,
- fashion of the lengths of the whiskers.

And keep this information in a table **cats_star**:
```
Table "public.cats_stat"
         Column         |   Type
------------------------+-----------
 tail_length_mean       | numeric
 tail_length_median     | numeric
 tail_length_mode       | integer[]
 whiskers_length_mean   | numeric
 whiskers_length_median | numeric
 whiskers_length_mode   | integer[]
```

It will look like this:
```
 tail_length_mean | tail_length_median | tail_length_mode
------------------+--------------------+------------------
             14.0 |               14.0 | {13,15}

 whiskers_length_mean | whiskers_length_median | whiskers_length_mode
----------------------+------------------------+----------------------
                 11.5 |                   11.5 | {11,12}
```

If you don't know, what is the average (mean), median (median) and fashion (mode), you'll find 
information about these basic units for statistics on the Internet.

**Implementation in the module  Wg.Animals.Cats, function count_cats_statistic.**

**The statistics function is implemented in module Wg.Stat.**

```
Wg.Animals.Cats.count_cats_statistic
```

**Possible to implement with ready-made libraries. For example:**

```
https://github.com/msharp/elixir-statistics
https://github.com/safwank/Numerix
```

# 3rd task

Good to have data, but even better to have a service that works with these data. We need an HTTP API.

To start you need to implement the method ping.

Write a program that will work as the web server on port 8080. On request:
```
curl -X GET http://localhost:8080/ping
```

will respond with a string:
```
"Cats Service. Version 0.1"
```

**Implementation in the module  WgWeb.HealthCheckController.**


# 4th task

Now need a method to retrieve a list of cats. On request:
```
curl -X GET http://localhost:8080/cats
```

A list of cats in JSON format should be returned:
```
[
  {"name": "Tihon", "color": "red & white", "tail_length": 15, "whiskers_length": 12},
  {"name": "Marfa", "color": "black & white", "tail_length": 13, "whiskers_length": 11}
]
```

Should work sort of a given attribute ascending or descending order:
```
curl -X 'GET http://localhost:8080/cats?attribute=name&order=asc'
curl -X 'GET http://localhost:8080/cats?attribute=tail_length&order=desc'
```

The client also needs to have the ability to query a subset of the data, putting the offset and limit:
```
curl -X 'GET http://localhost:8080/cats?offset=10&limit=10'
```

Of course, the client can specify and sort, and limit at the same time:
```
curl -X GET 'http://localhost:8080/cats?attribute=color&order=asc&offset=5&limit=2'
```

Think about what the server should return if a non-existent attribute is specified? Wrong order? Offset is larger than there is data in the database? What other options can there be for invalid requests?

Process such requests the way you think is right.

In this task, unit tests will not be superfluous, checking that your program correctly processes valid and invalid incoming data.

**Implementation in the modules Wg.Animals.Cats, WgWeb.CatController, Wg.Animals.Cats.Cat, Wg.Animals.Cats.Request ...**

**Covered by tests.**


# 5th task

Of course, our service must support the addition of new cats.

Append query looks like this:
```
curl -X POST http://localhost:8080/cat \
-d "{\"name\": \"Timmoha\", \"color\": \"red & white\", \"tail_length\": 15, \"whiskers_length\": 12}" \
-H 'Content-Type: application/json'
```

After receiving such a request, the service must save a new cat in the database.

There can also be many interesting situations here. What if the cat with the specified name is already in the database? And if the tail length is set as a negative number? Or is it not a number at all? And if the data is not a valid JSON object?

Think about what other situations are possible. Treat them the way you think is right. Don't forget about unit tests.

**Implementation in the modules Wg.Animals.Cats, Wg.Animals.Cats.Cat, WgWeb.CatController ...**

**Covered by tests.**


# 6th task

Good service should be ready for emergencies. For example, a certain group of customers accidentally or intentionally sends more requests to the service than the service can handle.

If the service is trying to serve all the requests at some point it will fall. But intelligent service knows its capabilities and operates within them. Extra requests, the service should be rejected.

The service needs to be setup, what is the number of requests it can serve. Let's say it's 600 requests per minute. If the number of requests from clients exceeds this limit, the number of requests the server must reject with HTTP status "429 Too Many Requests".

```
curl -X GET http://localhost:8080/cats
429 Too Many Requests
```

**Implementation in the modules WgWeb.RequestLimiter.Server, WgWeb.RequestLimiter.Plug ...**

**Covered by tests.**

**Possible to implement with ready-made libraries. For example:**

    https://github.com/ExHammer/hammer
    https://github.com/grempe/ex_rated

