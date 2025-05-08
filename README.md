# Sleep Tracker API

A Ruby on Rails API for tracking sleep patterns and following other users' sleep records.

## Features

- User authentication with authentication-zero
- Create and manage sleep records
- Follow/unfollow other users
- View sleep records of users you follow
- View sleep records sorted by duration

## Setup

### Prerequisites

- Ruby 3.4.1
- PostgreSQL 14+
- Docker and Docker Compose (optional, for containerized setup)

### Run The Application

1. Clone the repository

   ```bash
   git clone https://github.com/residwi/sleep-tracker-api.git
   cd sleep-tracker-api
   ```

1. Install dependencies

   ```bash
   bundle install
   ```

1. Setup the database

   ```bash
   rails db:prepare
   ```

1. Start the server

   ```bash
   rails server
   ```

### Docker Compose Setup

You can also run the application using Docker Compose, which sets up both the Rails application and PostgreSQL database in containers.

1. Clone the repository

   ```bash
   git clone https://github.com/residwi/sleep-tracker-api.git
   cd sleep-tracker-api
   ```

1. Build and start the containers

   ```bash
   docker compose up --build app
   ```

1. Access the application at http://localhost:3000

1. Running commands inside the container

   ```bash
   # Run Rails commands
   docker compose exec app rails c

   # Run tests
   docker compose exec app bundle exec rspec
   ```

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## Database Schema

The Sleep Tracker API uses a relational database with the following schema:

![Database Schema](https://uml.planttext.com/plantuml/png/fLJ1QiCm3BtxAqIFXVn0AAMdNdOP6piRjzOoCySEbaCfJVzzYfEHkJGZa9lytekb9yavK5GXjhKLz6qS14ye1BfeuXKs7uHX0ugWvG1k0c0BHaC9naMi6DhjNb_sUyQB8f5ErSWqnM1SbH2ibR4vr2YYYmzQQbCXnPmy1rGHjLGzhZcCfiR4j8r-mjodQjyjOlE6Pxuw5KtzMOO4B2c-DoaV5CT1iONK9jcdVAmBdNwAwpQeQBoRxbjhyEYjzPVaxJE5IrmDod-SZG8zArWp4YJY5WpZ6EBLaqYagZX5lZccaKhhm5bMRrHQzwuh2d_BjwY4BtPIAtVDDECq9dOQ4KzzgLBdUSTs_KavVdndGTSDRxA44rhlAeBeftiM2eF8pCt9nMyfiu83lm7-XVm0)

## API Documentation

### API Endpoints

#### Authentication

- `POST /api/v1/sign_in` - Sign in with email and password
- `DELETE /api/v1/sessions/:id` - Sign out

#### Sleep Records

- `GET /api/v1/sleep_records` - List current user's sleep records
- `POST /api/v1/sleep_records` - Create a new sleep record
- `GET /api/v1/sleep_records/:id` - Get a specific sleep record
- `PUT /api/v1/sleep_records/:id` - Update a sleep record
- `DELETE /api/v1/sleep_records/:id` - Delete a sleep record

#### Users

- `GET /api/v1/users` - List all users
- `GET /api/v1/users/:id` - Get user profile
- `GET /api/v1/users/:id/sleep_records` - Get a user's sleep records
- `GET /api/v1/users/:id/followers` - Get a user's followers
- `GET /api/v1/users/:id/following` - Get a user's following
- `POST /api/v1/users/:id/follow` - Follow a user
- `DELETE /api/v1/users/:id/unfollow` - Unfollow a user

#### Feeds

- `GET /api/v1/feeds` - Get sleep records of followed users from the previous week, sorted by duration

### Authentication Flow

![Authentication Flow](https://uml.planttext.com/plantuml/png/dLFBRi8m4BpxArQSg5JwKaySAXuHKaz5G7kjJB8GYs3JzGP4lxvh9w4fLAhK718dEpkpEwCCF6lYSbielp4Mo7bKIgVi2CQ5GSjg9tMJcfss39tXz1dcI7ka3cWFygeopNgfFK8dgK-nb8oKgXYWznI0VPY-p1TmwytQlejK5xVQ5DUmqzuV76LNAf0BDXdrOM9i1gL7WkKH8b0b8-WrJ3Faacm4D5tn-nkIMHrFb4eN3DFw1L97X2ahaAibDIRKZ63n01wzDyv6n2zoTHaEXdDWjq7xpINGQjiJEWAW-t1tNql8XbY8JwU1ZBqOgKKpB3cNWqar1r4aaaowZqBtQhNK79dFo6apfQoJ5SYiSmQtQf83c4YBBvSUFyeG18MdPzyFJH1wBZAQLP1gns4jKqsGeyxE_TQ5oO9xbHl1xaLSUnyAvqx7K1iJ9TTl2_yoEmRTOel0EJACIp7GyirFGCl5ARbKc9hLgmIg6Oqzc_AVvW_a9Z_G5m00)

### Authentication

#### Sign In

**Endpoint:** `POST /api/v1/sign_in`

**Authentication:** Not required

**Request Body:**

| Field    | Type   | Required | Description          | Validation                     |
| -------- | ------ | -------- | -------------------- | ------------------------------ |
| email    | String | Yes      | User's email address | Must be a valid email format   |
| password | String | Yes      | User's password      | Must match the stored password |

**Example Request Body:**

```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

#### Sign Out

**Endpoint:** `DELETE /api/v1/sessions/:id`

**Authentication:** Required

**URL Parameters:**

| Parameter | Type    | Required | Description                      |
| --------- | ------- | -------- | -------------------------------- |
| id        | Integer | Yes      | The ID of the session to destroy |

### Sleep Records

#### Create Sleep Record

**Endpoint:** `POST /api/v1/sleep_records`

**Authentication:** Required

**Request Body:**

| Field      | Type     | Required | Description                   | Validation                                |
| ---------- | -------- | -------- | ----------------------------- | ----------------------------------------- |
| start_time | DateTime | Yes      | When the sleep period started | Must be a valid ISO 8601 datetime         |
| end_time   | DateTime | No       | When the sleep period ended   | Must be later than start_time if provided |

**Example Request Body:**

```json
{
  "start_time": "2025-05-07T22:30:00Z",
  "end_time": "2025-05-08T06:45:00Z"
}
```

#### Update Sleep Record

**Endpoint:** `PUT /api/v1/sleep_records/:id`

**Authentication:** Required

**URL Parameters:**

| Parameter | Type    | Required | Description                          |
| --------- | ------- | -------- | ------------------------------------ |
| id        | Integer | Yes      | The ID of the sleep record to update |

**Request Body:**

| Field      | Type     | Required | Description                   | Validation                                |
| ---------- | -------- | -------- | ----------------------------- | ----------------------------------------- |
| start_time | DateTime | No       | When the sleep period started | Must be a valid ISO 8601 datetime         |
| end_time   | DateTime | No       | When the sleep period ended   | Must be later than start_time if provided |

**Example Request Body:**

```json
{
  "end_time": "2025-05-08T07:15:00Z"
}
```

### Users

#### Follow User

**Endpoint:** `POST /api/v1/users/:id/follow`

**Authentication:** Required

**URL Parameters:**

| Parameter | Type    | Required | Description                  |
| --------- | ------- | -------- | ---------------------------- |
| id        | Integer | Yes      | The ID of the user to follow |

**Request Body:** None required

#### Unfollow User

**Endpoint:** `DELETE /api/v1/users/:id/unfollow`

**Authentication:** Required

**URL Parameters:**

| Parameter | Type    | Required | Description                    |
| --------- | ------- | -------- | ------------------------------ |
| id        | Integer | Yes      | The ID of the user to unfollow |

**Request Body:** None required

## Performance Optimizations

The Sleep Tracker API includes several performance optimizations to handle a growing user base and high data volumes:

### Database Indexing Strategy

![Database Indexes](https://uml.planttext.com/plantuml/png/fPB1JWCX48RlFCMa5rkpVG7JD3rvyM8qdZTOncOY2vKPeiRuxWABTZMbQU8D-3_cd_bXmwA3nC4gVYO7mJCgTG4FZ851zAD586Vm3LcX4v9tcCMipK0pb1LyA81B80DN2HNSOO3LwlPclKxdosKHST1aayuIoEsI71szn5ewWP_PynwPoRkMBLUvE7zlpZ7FNVP_YD_65d4FTxZrmJJTCzE7aHbRc9xyju-icnYqfA6QmBnMwA0yMYyqu28nMp_iFPCSycpHtO_9yNibZcjlhNzj1V4qgYM2kZvd-14z7K1bp2bcFe6wQTN5uLSTcsk3pgHV_WK0)

### Query Optimization Techniques

1. **Eager Loading**

   I use eager loading to prevent N+1 query problems:

   ```ruby
   SleepRecord.where(user_id: following_ids).includes(:user)
   ```

1. **Selective Column Fetching**

   Only necessary columns are fetched to reduce memory usage:

   ```ruby
   SleepRecord.select(:id, :start_time, :end_time, :duration, :user_id)
   ```

### Pagination Implementation

The API uses keyset pagination for efficient handling of large datasets:

```ruby
@pagy, @records = pagy_keyset(@sleep_records, items: 20)

render json: {
  data: @records,
  pagination: {
    next: pagy_url_for(@pagy, @pagy.next, absolute: true)
  }
}
```

Keyset pagination offers several advantages over traditional offset-based pagination:

- Consistent performance regardless of page depth
- No issues with records shifting during pagination
- Better performance with large datasets

### Redis Consideration

While Redis is a powerful tool for caching and can significantly improve performance,
I have made a deliberate decision to delay its implementation initially. Because:

1. **Measurement First Approach**

   - I prioritize measuring actual performance bottlenecks before implementing solutions
   - This prevents premature optimization and unnecessary complexity

1. **Cost Considerations**

   - Redis adds operational costs (hosting, maintenance, monitoring)
   - For new applications, it's important to validate the need before incurring these costs

1. **Current Optimization Alternatives**

   - Database indexing strategy
   - Query optimization techniques
   - Selective column fetching
   - Keyset pagination
   - These optimizations often provide significant performance improvements without additional infrastructure

1. **Implementation Criteria**
   - Redis will be considered when:
     - Response times consistently exceed performance targets
     - Database load becomes a bottleneck
     - Specific endpoints show high cache hit potential
     - User base grows beyond what database-only optimizations can handle
