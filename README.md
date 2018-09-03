## Check Application Health

The purpose of this gem is to provide a simple mechanism to define health checks for and application. Those health checks can then be monitored from a web endpoint or from application code.

Some ways to use the health checks:

* Use them as documentation for the services that you expect to be available for your appliction to function.
* Expose one or more health checks as web endpoints and monitor them with an uptime service to get alerts when something goes wrong.
* Add a pre-deployment task that excercises your production configurations so that you don't take your application down with bad or missing settings.

## Defining & Registering Checks

Checks can be defined with either a block or an instance of `IsItBroken::Check`. If you have complex logic, you can subclass `IsItBroken::Check` to make your life easier.

### Define a check with a block

```ruby
```

### Define a check with an object

```ruby
```

### Define a more complex check

```ruby
```

## Performance & Threading

Make sure to setup timeouts if you implement checks that make network calls. Otherwise when something does go wrong, your monitoring endoints will just hang indefinitely.

If you open any connections, make sure you close them or your monitoring could become the source of problems.

Make sure you don't have any checks that will take longer to finish than your monitoring service can handle. Otherwise you risk getting a backup in requests caused by monitoring which over time could become a problem.

Don't expose any information that could make your site insecure if you have publicly accessible monitoring endpoints.

## Examples

