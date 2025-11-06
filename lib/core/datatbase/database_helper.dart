import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,  // Increment version
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Drop old table and recreate
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS movies');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT,
        vote_average REAL,
        vote_count INTEGER,
        popularity REAL,
        original_language TEXT,
        genre_ids TEXT,
        isBookmarked INTEGER DEFAULT 0,
        category TEXT,
        runtime INTEGER,
        genres TEXT,
        status TEXT,
        tagline TEXT
      )
    ''');

    // Add index for faster searches
    await db.execute('CREATE INDEX idx_title ON movies(title)');
    await db.execute('CREATE INDEX idx_category ON movies(category)');
  }

  Future<void> insertMovie(Movie movie, {String category = ''}) async {
    final db = await database;

    final movieMap = movie.toJson();

    // Convert List<int> to JSON string for SQLite storage
    if (movieMap['genre_ids'] is List) {
      movieMap['genre_ids'] = json.encode(movieMap['genre_ids']);
    }
    if (movieMap['genres'] is List) {
      movieMap['genres'] = json.encode(movieMap['genres']);
    }

    await db.insert(
      'movies',
      {
        ...movieMap,
        'category': category,
        'isBookmarked': movie.isBookmarked ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMovies(List<Movie> movies, String category) async {
    final db = await database;
    final batch = db.batch();

    for (var movie in movies) {
      final movieMap = movie.toJson();

      // Convert List<int> to JSON string
      if (movieMap['genre_ids'] is List) {
        movieMap['genre_ids'] = json.encode(movieMap['genre_ids']);
      }
      if (movieMap['genres'] is List) {
        movieMap['genres'] = json.encode(movieMap['genres']);
      }

      batch.insert(
        'movies',
        {
          ...movieMap,
          'category': category,
          'isBookmarked': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Movie>> getMoviesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'popularity DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);

      // Decode JSON strings back to Lists
      if (map['genre_ids'] != null && map['genre_ids'] is String) {
        try {
          map['genre_ids'] = json.decode(map['genre_ids']);
        } catch (_) {
          map['genre_ids'] = [];
        }
      }
      if (map['genres'] != null && map['genres'] is String) {
        try {
          final decoded = json.decode(map['genres']);
          map['genres'] = decoded;
        } catch (_) {
          map['genres'] = [];
        }
      }

      return Movie.fromJson(map)..isBookmarked = maps[i]['isBookmarked'] == 1;
    });
  }

  Future<Movie?> getMovieById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = Map<String, dynamic>.from(maps.first);

    // Decode JSON strings back to Lists
    if (map['genre_ids'] != null && map['genre_ids'] is String) {
      try {
        map['genre_ids'] = json.decode(map['genre_ids']);
      } catch (_) {
        map['genre_ids'] = [];
      }
    }
    if (map['genres'] != null && map['genres'] is String) {
      try {
        map['genres'] = json.decode(map['genres']);
      } catch (_) {
        map['genres'] = [];
      }
    }

    return Movie.fromJson(map)..isBookmarked = maps.first['isBookmarked'] == 1;
  }

  Future<void> updateMovieBookmark(int id, bool isBookmarked) async {
    final db = await database;
    await db.update(
      'movies',
      {'isBookmarked': isBookmarked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Movie>> getBookmarkedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'isBookmarked = ?',
      whereArgs: [1],
      orderBy: 'title ASC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);

      // Decode JSON strings back to Lists
      if (map['genre_ids'] != null && map['genre_ids'] is String) {
        try {
          map['genre_ids'] = json.decode(map['genre_ids']);
        } catch (_) {
          map['genre_ids'] = [];
        }
      }
      if (map['genres'] != null && map['genres'] is String) {
        try {
          map['genres'] = json.decode(map['genres']);
        } catch (_) {
          map['genres'] = [];
        }
      }

      return Movie.fromJson(map)..isBookmarked = true;
    });
  }

  Future<List<Movie>> searchMovies(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'popularity DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);

      // Decode JSON strings back to Lists
      if (map['genre_ids'] != null && map['genre_ids'] is String) {
        try {
          map['genre_ids'] = json.decode(map['genre_ids']);
        } catch (_) {
          map['genre_ids'] = [];
        }
      }
      if (map['genres'] != null && map['genres'] is String) {
        try {
          map['genres'] = json.decode(map['genres']);
        } catch (_) {
          map['genres'] = [];
        }
      }

      return Movie.fromJson(map)..isBookmarked = maps[i]['isBookmarked'] == 1;
    });
  }

  Future<void> clearCategory(String category) async {
    final db = await database;
    await db.delete(
      'movies',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

