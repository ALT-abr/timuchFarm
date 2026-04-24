import 'package:sqflite/sqflite.dart';

class DatabaseSeed {
  DatabaseSeed._();

  static Future<void> seedIfEmpty(Database db) async {
    final cowCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM cows'),
    );

    if ((cowCount ?? 0) > 0) {
      return;
    }

    await seedAll(db);
  }

  static Future<void> clearAll(Database db) async {
    await db.transaction((txn) async {
      await txn.delete('foods');
      await txn.delete('milk_productions');
      await txn.delete('notes');
      await txn.delete('cows');
      await txn.delete('users');
    });
  }

  static Future<void> resetAndSeed(Database db) async {
    await clearAll(db);
    await seedAll(db);
  }

  static Future<void> seedAll(Database db) async {
    final now = DateTime.now();

    await db.transaction((txn) async {
      await txn.insert('users', {
        'username': 'iamthefarmer',
        'first_name': 'Taseda',
        'password': '12345678',
        'email': 'wealthyfarmer@gmail.com',
        'phone': '+33 6 12 34 56 78',
        'creation_date': now.toIso8601String(),
        'address': 'Timuch Farm, Tifra',
      });

      final cows = [
        {
          'code': '15:04088',
          'name': 'Bessie',
          'breed': 'Holstein',
          'age': 5,
          'status': 'Milking',
          'health': 'Healthy',
          'created_at': now.toIso8601String(),
        },
        {
          'code': '15:140088',
          'name': 'Daisy',
          'breed': 'Jersey',
          'age': 3,
          'status': 'Milking',
          'health': 'Healthy',
          'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'code': '15:140888',
          'name': 'Buttercup',
          'breed': 'Holstein',
          'age': 6,
          'status': 'Dry',
          'health': 'In Heat',
          'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        },
        {
          'code': '15:280111',
          'name': 'Bella',
          'breed': 'Montbeliarde',
          'age': 4,
          'status': 'Pregnant',
          'health': 'Monitoring',
          'created_at': now.subtract(const Duration(days: 6)).toIso8601String(),
        },
        {
          'code': '15:390222',
          'name': 'Luna',
          'breed': 'Brown Swiss',
          'age': 2,
          'status': 'Growing',
          'health': 'Healthy',
          'created_at': now.subtract(const Duration(days: 8)).toIso8601String(),
        },
      ];

      for (final cow in cows) {
        await txn.insert('cows', cow);
      }

      final notes = [
        {
          'title': 'Check cows for health issues',
          'description': 'Some cows looked sluggish and need quick inspection.',
          'category': 'Urgent',
          'priority': 'high',
          'due_date': now.toIso8601String(),
          'created_at': now.toIso8601String(),
        },
        {
          'title': 'Schedule vet visit',
          'description': 'Routine check planned for next Friday at 10 AM.',
          'category': 'Planning',
          'priority': 'medium',
          'due_date': now.add(const Duration(days: 2)).toIso8601String(),
          'created_at': now.toIso8601String(),
        },
        {
          'title': 'Clean the feeding area',
          'description': 'Wash containers and remove spoiled leftovers.',
          'category': 'Maintenance',
          'priority': 'medium',
          'due_date': now.add(const Duration(days: 1)).toIso8601String(),
          'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        },
        {
          'title': 'Update stock prices',
          'description': 'Review the latest supplier prices for feed bags.',
          'category': 'Admin',
          'priority': 'low',
          'due_date': now.add(const Duration(days: 5)).toIso8601String(),
          'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        },
      ];

      for (final note in notes) {
        await txn.insert('notes', note);
      }

      final productions = [
        {
          'quantity': 180.0,
          'production_date': now.toIso8601String(),
          'moment': 'morning',
        },
        {
          'quantity': 165.5,
          'production_date': now.toIso8601String(),
          'moment': 'evening',
        },
        {
          'quantity': 200.0,
          'production_date':
              now.subtract(const Duration(days: 1)).toIso8601String(),
          'moment': 'morning',
        },
        {
          'quantity': 192.0,
          'production_date':
              now.subtract(const Duration(days: 1)).toIso8601String(),
          'moment': 'evening',
        },
        {
          'quantity': 188.0,
          'production_date':
              now.subtract(const Duration(days: 2)).toIso8601String(),
          'moment': 'morning',
        },
      ];

      for (final production in productions) {
        await txn.insert('milk_productions', production);
      }

      final foods = [
        {
          'name': 'THUGA',
          'stock': 410.0,
          'unit': 'Botte',
          'category': 'Fourrage',
          'purchase_date': now.toIso8601String(),
          'unit_price': 1.5,
          'daily_consumption': 12.0,
          'photo_path': 'assets/images/tugha.jpg',
        },
        {
          'name': 'ALIMENT',
          'stock': 54.0,
          'unit': 'Sac',
          'category': 'Concentre',
          'purchase_date':
              now.subtract(const Duration(days: 5)).toIso8601String(),
          'unit_price': 25.0,
          'daily_consumption': 2.5,
          'photo_path': 'assets/images/aliment.jpg',
        },
        {
          'name': 'FOIN PREMIUM',
          'stock': 240.0,
          'unit': 'Kg',
          'category': 'Fourrage',
          'purchase_date':
              now.subtract(const Duration(days: 2)).toIso8601String(),
          'unit_price': 3.4,
          'daily_consumption': 8.0,
          'photo_path': null,
        },
        {
          'name': 'MINERAL MIX',
          'stock': 32.0,
          'unit': 'Sac',
          'category': 'Complement',
          'purchase_date':
              now.subtract(const Duration(days: 7)).toIso8601String(),
          'unit_price': 18.75,
          'daily_consumption': 1.25,
          'photo_path': null,
        },
      ];

      for (final food in foods) {
        await txn.insert('foods', food);
      }
    });
  }
}
