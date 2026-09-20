---
name: ruby-gems-io-services
description: Use for RubyGems, dependency usage, filesystem/CSV work, HTTP integration and service-object design.
---

# Ruby Gems, I/O and Services

## Purpose
Encapsulate external boundaries and operational workflows so application code remains understandable and testable.

## Dependencies
Before adding a gem:
1. inspect existing dependencies
2. verify the supported Ruby version
3. check whether the standard library already solves the problem
4. consider maintenance/security/project policy
5. keep the dependency boundary narrow

## File and CSV I/O
Treat I/O as a boundary. Use safe file lifecycle patterns, validate external data and separate reading, parsing, transformation and persistence.

## HTTP
Keep external requests behind a dedicated client/service boundary defining request details, authentication, timeout behavior, response parsing, status handling and error mapping.

Do not scatter HTTP calls across controllers and models.

## Service objects
Use a service object for a coherent workflow involving multiple steps or multiple concepts.

~~~
ruby
OrderCheckout.new(order).call
~~~

A service should remain focused. Avoid turning it into a generic Manager or god object.

## Failure handling
Do not silently swallow I/O or HTTP errors. Follow the application's established error strategy and log useful context without secrets.

## Source foundation
Based on RubyGems, file/CSV, HTTP and service-object material from The Ruby Workshop, with SRP guidance from the source books.