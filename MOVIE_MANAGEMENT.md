# CineSmart Movie Management

This guide shows how to manage movies in your CineSmart app in real-time, just like BookMyShow.

## 🎬 Movie Management Features

Your app now supports:
- **Dynamic movie database** - Movies stored in SQLite database
- **Real-time updates** - Add, update, delete movies instantly
- **Genre filtering** - Filter movies by genre in the app
- **Search functionality** - Search movies by title
- **Admin tools** - Command-line tools to manage movies

## 📊 API Endpoints

### Get Movies
```
GET /movies/
GET /movies/?genre=Action
```

### Get Genres
```
GET /movies/genres
```

### CRUD Operations
```
POST /movies/          # Create movie
GET /movies/{id}       # Get specific movie
PUT /movies/{id}       # Update movie
DELETE /movies/{id}    # Delete movie
```

## 🛠️ Managing Movies

### Using the Admin Script

Run the movie management script:

```bash
cd backend_fastapi
python manage_movies.py <command>
```

Commands:
- `list` - Show all movies
- `add` - Add a new movie
- `update` - Update existing movie
- `delete` - Remove a movie

Example:
```bash
python manage_movies.py add
# Follow prompts to enter movie details
```

### Manual Database Management

You can also use any SQLite browser or write Python scripts to manage movies directly.

## 🎭 Adding New Movies

When adding movies, include:
- **Title** - Movie name
- **Description** - Brief plot summary
- **Genre** - Category (Action, Drama, Sci-Fi, etc.)
- **Rating** - IMDb-style rating (0-10)
- **Duration** - Runtime in minutes
- **Image URL** - Poster image URL

## 🔄 Real-time Updates

Since the app fetches movies from the database:
1. Add/update movies using the admin script
2. The changes appear immediately in the app
3. Users can filter by genre and search
4. Pull-to-refresh to get latest data

## 📱 App Features

- **Search** - Type in search bar to find movies
- **Genre Filter** - Dropdown to filter by movie type
- **Pull to Refresh** - Swipe down to refresh movie list
- **Real-time Data** - All changes reflect immediately

Your CineSmart app now works like BookMyShow with dynamic, real-time movie management! 🎬✨