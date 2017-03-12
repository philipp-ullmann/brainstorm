# Demo Brainstorming Rails API application [![Build Status](https://travis-ci.org/philipp-ullmann/brainstorm.svg?branch=master)](https://travis-ci.org/philipp-ullmann/brainstorm) [![Code Climate](https://codeclimate.com/github/philipp-ullmann/brainstorm/badges/gpa.svg)](https://codeclimate.com/github/philipp-ullmann/brainstorm)

This is a demo brainstorming rails JSON API application. At first an user makes a registration with an unique username. The login is done via username and password. After successful login an user can list all existing brainstorming trees, can add a new term to an existing brainstorming tree or create a new brainstorming tree.

![Kiku](doc/images/health.jpg)

Used technologies and versions:

* docker         1.13.1
* docker-compose 1.11.1
* mysql          5.7.17
* ruby           2.4.0
* rails          5.0.2
* rspec-rails    3.5.2
* JSON Web Token authentication

Start the application with `docker-compose up -d`. Generate test data with `docker-compose exec web rake db:seed`. The application run's on port 3000. Setup test database with `docker-compose exec web rake db:setup`. Run tests with `docker-compose exec web rake spec`.

## API

**Registrate a new user:**

    curl -H "Content-Type: application/json" -X POST -d '{"username":"test","password":"secret","password_confirmation":"secret"}' http://docker:3000/register

```json
{
  "id":         3,
  "username":   "philipp",
  "auth_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE0ODg2NTUwOTh9.tufeV0v5wM06vbiZTLQqZfPUu6jZHhu2HkyvO3JTLs4"
}
```

**Authenticate an user:**

    curl -H "Content-Type: application/json" -X POST -d '{"username":"philipp","password":"secret"}' http://docker:3000/login 

```json
{
  "id":         3,
  "username":   "philipp",
  "auth_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE0ODg2NTUwOTh9.tufeV0v5wM06vbiZTLQqZfPUu6jZHhu2HkyvO3JTLs4"
}
```

**List all available brainstorming terms:**

    curl -H "Content-Type: application/json" -H "Authorization: <auth_token>" http://docker:3000

```json
[
  {
    "id":         1,
    "name":       "Health",
    "owned_by":   "philipp",
    "created_at": "2017-03-04 09:06:33",
    "updated_at": "2017-03-04 09:06:33"
  }
]
```

**Show a whole brainstorming tree:**

    curl -H "Content-Type: application/json" -H "Authorization: <auth_token>" http://docker:3000/terms/1

```json
{
  "id":         1,
  "name":       "Health",
  "owned_by":   "philipp",
  "created_at": "2017-03-04 09:06:33",
  "updated_at": "2017-03-04 09:06:33",
  "children":
    [
      {
        "id":         2,
        "name":       "Sleep",
        "owned_by":   "philipp",
        "created_at": "2017-03-04 09:06:33",
        "updated_at": "2017-03-04 09:06:33",
        "children":   []
      }
    ]
}
```

**Create a new root brainstorming term:**

    curl -H "Content-Type: application/json" -H "Authorization: <auth_token>" -X POST -d '{"name":"Climbing"}' http://docker:3000/terms

```json
{
  "id":         3,
  "name":       "Climbing",
  "owned_by":   "philipp",
  "created_at": "2017-03-04 09:06:33",
  "updated_at": "2017-03-04 09:06:33",
  "children":   []
}
```

**Create a new child term:**

    curl -H "Content-Type: application/json" -H "Authorization: <auth_token>" -X POST -d '{"name":"Climbing"}' http://docker:3000/terms?parent_id=1

```json
{
  "id":         3,
  "name":       "Climbing",
  "owned_by":   "philipp",
  "created_at": "2017-03-04 09:06:33",
  "updated_at": "2017-03-04 09:06:33",
  "children":   []
}
```

**Update a term:**

    curl -H "Content-Type: application/json" -H "Authorization: <auth_token>" -X PUT -d '{"name":"Stress"}' http://docker:3000/terms/2

```json
{
  "id":         2,
  "name":       "Stress",
  "owned_by":   "philipp",
  "created_at": "2017-03-04 09:06:33",
  "updated_at": "2017-03-04 09:06:33",
  "children":   []
}
```
