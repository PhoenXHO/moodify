This file contains the description of the database schema for the project. It outlines the tables, their fields, and relationships between them. This document serves as a reference for developers to understand the structure of the database and how to interact with it.

# Database Schema

## `users` Table
This table is in the `auth` schema and contains information about the users of the application. It stores user credentials and profile information. It is used for authentication and authorization purposes, and it is automatically created and managed by the Supabase authentication system.

The rest of the tables are in the `public` schema and are used to store application-specific data.

## `songs` Table
This table  contains information about the songs in the application. It stores details such as the song title, artist, genres, and the moods corresponding to the song in the storage bucket.
| Field Name     | Data Type         | Description                                        | Default Value       | Nullable |
|----------------|-------------------|----------------------------------------------------|---------------------|----------|
| `id`           | UUID              | Unique identifier for the song (primary key)       | `gen_random_uuid()` | No       |
| `title`        | Text              | Title of the song                                  | ""                  | No       |
| `artist`       | Text              | Artist of the song                                 | ""                  | No       |
| `genres`       | JSONB             | Genres associated with the song (array of strings) | []                  | No       |
| `moods`        | JSONB             | Moods associated with the song (array of strings)  | []                  | No       |
| `favorites`    | INT8              | Number of favorites for the song                   | 0                   | No       |
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

## `playlists` Table
This table contains information about user-created playlists. It stores playlist metadata and ownership information.

| Field Name     | Data Type         | Description                                        | Default Value       | Nullable |
|----------------|-------------------|----------------------------------------------------|---------------------|----------|
| `id`           | UUID              | Unique identifier for the playlist (primary key)   | `gen_random_uuid()` | No       |
| `user_id`      | UUID              | Owner of the playlist (references auth.users)      | ""                  | No       |
| `title`        | Text              | Name of the playlist                               | ""                  | No       |
| `description`  | Text              | Description of the playlist                        | NULL                | Yes      |
| `is_public`    | Boolean           | Whether the playlist is publicly visible           | FALSE               | No       |
| `song_count`   | Integer           | Number of songs in the playlist                    | 0                   | No       |
| `created_at`   | Timestamp         | When the playlist was created                      | `now()`             | No       |
| `updated_at`   | Timestamp         | When the playlist was last modified                | `now()`             | No       |

In this table, the `user_id` field is a foreign key referencing the id field in the `auth.users` table. This establishes ownership of each playlist by a specific user. The id field serves as the primary key, uniquely identifying each playlist in the system.


## `playlist_songs` Table
This table establishes the relationship between playlists and songs, maintaining the order of songs within each playlist.

| Field Name     | Data Type                | Description                                        | Default Value       | Nullable |
|----------------|--------------------------|----------------------------------------------------|---------------------|----------|
| `id`           | UUID                     | Unique identifier for the entry (primary key)      | `gen_random_uuid()` | No       |
| `playlist_id`  | UUID                     | Reference to the parent playlist                   | ""                  | No       |
| `song_id`      | UUID                     | Reference to the song                              | ""                  | No       |
| `position`     | Integer                  | Order of the song in playlist (0-indexed)          | 0                   | No       |
| `added_by`     | UUID                     | User who added this song                           | NULL                | Yes      |
| `added_at`     | Timestamp                | When the song was added to playlist                | `now()`             | No       |
| `PRIMARY_KEY`  | (playlist_id, song_id)   | Ensures unique song per playlist                   |                     |          |

In this table:

- The `playlist_id` field is a foreign key referencing the id field in the `playlists` table (ON DELETE CASCADE)

- The `song_id` field is a foreign key referencing the id field in the `songs` table (ON DELETE CASCADE)

- The `added_by` field is a foreign key referencing the `id` field in the `auth.users` table (ON DELETE SET NULL)

- The combination of `playlist_id` and `song_id` serves as a unique constraint, ensuring that each song can only appear once in a given playlist

- The `id` field serves as the primary key, while the `position` field maintains the specific ordering of songs within each playlist

- These relationships ensure referential integrity while supporting the many-to-many relationship between playlists and songs, where:

    + A single playlist can contain many songs

    + A single song can belong to many playlists

    + Each playlist maintains its own ordered sequence of songs
