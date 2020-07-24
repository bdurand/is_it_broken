![Continuous Integration](https://github.com/bdurand/is_it_broken/workflows/Continuous%20Integration/badge.svg)

[![Maintainability](https://api.codeclimate.com/v1/badges/a92d5701481268471d53/maintainability)](https://codeclimate.com/github/bdurand/is_it_broken/maintainability)

[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

# Is It Broken?

The purpose of this gem is to provide a simple mechanism to define health checks for and application. Those health checks can then be monitored from a web endpoint or from application code.

Some ways to use the health checks:

* Use them as documentation for the services that you expect to be available for your application to function.
* Expose one or more health checks as web endpoints and monitor them with an uptime service to get alerts when something goes wrong.
* Add a pre-deployment task that exercises your production configurations so that you don't take your application down with bad or missing settings.

## Defining & Registering Checks

Checks can be defined with either a block or an instance of `IsItBroken::Check`. If you have complex logic, you can subclass `IsItBroken::Check` to make your life easier.

### Define a check with a block

```ruby
# TODO: Define check block example
```

### Define a check with an object

```ruby
# TODO: Define check object example
```

### Define a more complex check

```ruby
# TODO: Define complex check example
```

## Performance & Threading

Make sure to setup timeouts if you implement checks that make network calls. Otherwise when something does go wrong, your monitoring endpoints will just hang indefinitely.

If you open any connections, make sure you close them or your monitoring could become the source of problems.

Make sure you don't have any checks that will take longer to finish than your monitoring service can handle. Otherwise you risk getting a backup in requests caused by monitoring which over time could become a problem.

Don't expose any information that could make your site insecure if you have publicly accessible monitoring endpoints.

## Examples
