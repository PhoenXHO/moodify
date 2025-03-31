This file contains the description of the database schema for the project. It outlines the tables, their fields, and relationships between them. This document serves as a reference for developers to understand the structure of the database and how to interact with it.

# Database Schema

## `users` Table
This table is in the `auth` schema and contains information about the users of the application. It stores user credentials and profile information. It is used for authentication and authorization purposes, and it is automatically created and managed by the Supabase authentication system.

The rest of the tables are in the `public` schema and are used to store application-specific data.

## `songs` Table
This table  contains information about the songs in the application. It stores details such as the song title, artist, genres, moods, and the file path of the song in the storage bucket.
| Field Name     | Data Type         | Description                                        | Default Value       | Nullable |
|----------------|-------------------|----------------------------------------------------|---------------------|----------|
| `id`           | UUID              | Unique identifier for the song (primary key)       | `gen_random_uuid()` | No       |
| `title`        | Text              | Title of the song                                  | ""                  | No       |
| `artist`       | Text              | Artist of the song                                 | ""                  | No       |
| `genres`       | JSONB             | Genres associated with the song (array of strings) | []                  | No       |
| `moods`        | JSONB             | Moods associated with the song (array of strings)  | []                  | No       |
| `favorites`    | INT8              | Number of favorites for the song                   | 0                   | No       |
| `file_path`    | Text              | File path of the song in the storage bucket        | ""                  | No       |
| `created_at`   | Timestamp         | Timestamp when the song was created                | `now()`             | No       |

## `favorites` Table
This table contains information about the favorite songs of users. It stores the user ID and the song ID, creating a many-to-many relationship between users and songs. Each user can have multiple favorite songs, and each song can be favorited by multiple users.
| Field Name     | Data Type          | Description                                        | Default Value       | Nullable |
|----------------|--------------------|----------------------------------------------------|---------------------|----------|
| `user_id`      | UUID               | Unique identifier for the user                     | ""                  | No       |
| `song_id`      | UUID               | Unique identifier for the song                     | ""                  | No       |
| `created_at`   | Timestamp          | Timestamp when the favorite was created            | `now()`             | No       |
| `PRIMARY_KEY`  | (user_id, song_id) | Composite primary key for user and song            |                     |          |

In this table, the `user_id` and `song_id` fields are foreign keys referencing the `id` field in the `users` and `songs` tables, respectively. The combination of `user_id` and `song_id` serves as the primary key for this table, ensuring that each user can only favorite a song once.