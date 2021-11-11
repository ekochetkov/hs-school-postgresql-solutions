# Solutions for the Postgres course by [Health Samurai](https://www.health-samurai.io/jobs/pg-course)

## Before start

1. Build and up db-service by docker-compose:
    ```
    $ docker-compose up -d --build
    ```

2. Set env variable for connection without password prompt for education porpose only:
    ```
    PGPASSWORD=postgres
    ```

3. Check connection:
    ```
    $ psql -h localhost -p 5400 -U postgres -c "\l"
    ```
    expected output "List of databases".
