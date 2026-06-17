import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screat_app/data/models/chat_message_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyUserGender = 'string_user_gender';
  static const String _keyIsOnboardingCompleted = 'bool_is_onboarding_completed';
  static const String _keyChatHistoryPrefix = 'chat_history_';

  // --- Gender Selection ---
  Future<void> setUserGender(String gender) async {
    await _secureStorage.write(key: _keyUserGender, value: gender);
  }

  Future<String?> getUserGender() async {
    return await _secureStorage.read(key: _keyUserGender);
  }

  // --- Onboarding Flow ---
  Future<void> setOnboardingCompleted(bool completed) async {
    await _secureStorage.write(
      key: _keyIsOnboardingCompleted,
      value: completed.toString(),
    );
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await _secureStorage.read(key: _keyIsOnboardingCompleted);
    return value == 'true';
  }

  // --- Chat History Storage ---
  Future<void> saveChatHistory(String mode, List<ChatMessageModel> messages) async {
    final String key = '$_keyChatHistoryPrefix$mode';
    final List<Map<String, dynamic>> jsonList = messages.map((m) => m.toJson()).toList();
    final String jsonString = jsonEncode(jsonList);
    await _secureStorage.write(key: key, value: jsonString);
  }

  Future<List<ChatMessageModel>> getChatHistory(String mode) async {
    final String key = '$_keyChatHistoryPrefix$mode';
    final String? jsonString = await _secureStorage.read(key: key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => ChatMessageModel.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing chat history for $mode: $e');
      return [];
    }
  }

  Future<void> clearChatHistory(String mode) async {
    final String key = '$_keyChatHistoryPrefix$mode';
    await _secureStorage.delete(key: key);
  }

  // --- Clear Storage ---
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // --- Rights Management ---
  static const String _keyRemainingRights = 'int_remaining_rights';

  Future<int> getRemainingRights() async {
    final String? value = await _secureStorage.read(key: _keyRemainingRights);
    if (value == null) {
      // Eğer cihazda daha önce kaydedilmiş bir hak yoksa, varsayılan olarak 2 hak tanımla.
      await setRemainingRights(2);
      return 2;
    }
    return int.tryParse(value) ?? 0;
  }

  Future<void> setRemainingRights(int rights) async {
    await _secureStorage.write(key: _keyRemainingRights, value: rights.toString());
  }
}
