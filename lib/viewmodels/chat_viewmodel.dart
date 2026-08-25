import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screat_app/data/models/chat_message_model.dart';
import 'package:screat_app/data/services/chat_api_service.dart';
import 'package:screat_app/data/services/local_storage_service.dart';
import 'package:screat_app/data/services/ad_service.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isLoading;
  
  ChatState({required this.messages, this.isLoading = false});
  
  ChatState copyWith({List<ChatMessageModel>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatViewModel extends Notifier<ChatState> {
  final ChatApiService _apiService = ChatApiService();
  final LocalStorageService _storageService = LocalStorageService();

  @override
  ChatState build() {
    return ChatState(messages: []);
  }

  /// Loads chat history for the specified mode from secure storage
  Future<void> loadChatHistory(String mode) async {
    state = state.copyWith(isLoading: true);
    final history = await _storageService.getChatHistory(mode);
    state = ChatState(messages: history, isLoading: false);
  }

  Future<void> sendMessage(String mode, String text, String selectedTone) async {
    if (text.trim().isEmpty) return;
    
    final userMsg = ChatMessageModel(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
    );
    
    // Save history with user message
    await _storageService.saveChatHistory(mode, updatedMessages);
    
    try {
      final aiResponse = await _apiService.generateResponse(mode, text, selectedTone);
      final aiMsg = ChatMessageModel(
        isUser: false,
        text: aiResponse,
        timestamp: DateTime.now(),
      );
      
      final finalMessages = [...state.messages, aiMsg];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );
      
      // Save history with AI response
      await _storageService.saveChatHistory(mode, finalMessages);
    } catch (e) {
      final errorMsg = ChatMessageModel(
        isUser: false,
        text: 'Bir hata oluştu: $e',
        timestamp: DateTime.now(),
      );
      
      final finalMessages = [...state.messages, errorMsg];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );
      
      // Save history with error message
      await _storageService.saveChatHistory(mode, finalMessages);
    }
  }

  void clearChatHistoryWithReward(String mode) {
    AdService().showRewardedAd(
      onRewarded: () async {
        await _storageService.clearChatHistory(mode);
        state = state.copyWith(messages: []);
      },
    );
  }
}

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(() {
  return ChatViewModel();
});
