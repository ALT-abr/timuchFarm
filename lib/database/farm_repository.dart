import 'package:sqflite/sqflite.dart';
import 'package:timuchmilk/database/app_database.dart';
import 'package:timuchmilk/models/cow_model.dart';
import 'package:timuchmilk/models/food_model.dart';
import 'package:timuchmilk/models/milk_production_model.dart';
import 'package:timuchmilk/models/note_model.dart';
import 'package:timuchmilk/models/user_model.dart';

class FarmRepository {
  FarmRepository._();

  static final FarmRepository instance = FarmRepository._();

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<CowModel>> getCows() async {
    final rows = await (await _db).query('cows', orderBy: 'created_at DESC');
    return rows.map(CowModel.fromMap).toList();
  }

  Future<int> addCow(CowModel cow) async {
    return (await _db).insert('cows', cow.toMap());
  }

  Future<int> updateCow(CowModel cow) async {
    return (await _db).update(
      'cows',
      cow.toMap(),
      where: 'id = ?',
      whereArgs: [cow.id],
    );
  }

  Future<int> deleteCow(int id) async {
    return (await _db).delete(
      'cows',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<UserModel>> getUsers() async {
    final rows = await (await _db).query('users', orderBy: 'creation_date DESC');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getLatestUser() async {
    final rows = await (await _db).query(
      'users',
      orderBy: 'creation_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserModel.fromMap(rows.first);
  }

  Future<int> addUser(UserModel user) async {
    return (await _db).insert('users', user.toMap());
  }

  Future<int> updateUser(UserModel user) async {
    return (await _db).update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<NoteModel>> getNotes() async {
    final rows = await (await _db).query('notes', orderBy: 'due_date DESC');
    return rows.map(NoteModel.fromMap).toList();
  }

  Future<int> addNote(NoteModel note) async {
    return (await _db).insert('notes', note.toMap());
  }

  Future<int> deleteNote(int id) async {
    return (await _db).delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MilkProductionModel>> getMilkProductions() async {
    final rows = await (await _db).query(
      'milk_productions',
      orderBy: 'production_date DESC',
    );
    return rows.map(MilkProductionModel.fromMap).toList();
  }

  Future<int> addMilkProduction(MilkProductionModel production) async {
    return (await _db).insert('milk_productions', production.toMap());
  }

  Future<List<FoodModel>> getFoods() async {
    final rows = await (await _db).query('foods', orderBy: 'name ASC');
    return rows.map(FoodModel.fromMap).toList();
  }

  Future<int> addFood(FoodModel food) async {
    return (await _db).insert('foods', food.toMap());
  }

  Future<int> updateFood(FoodModel food) async {
    return (await _db).update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFood(int id) async {
    return (await _db).delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
