import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:screat_app/core/constants/color_constants.dart';
import 'package:screat_app/data/services/ad_service.dart';
import 'package:screat_app/data/services/local_storage_service.dart';
import 'package:screat_app/viewmodels/chat_viewmodel.dart';
import 'package:screat_app/data/models/chat_message_model.dart';
import 'package:image_picker/image_picker.dart';

class ChatView extends ConsumerStatefulWidget {
  final String mode;
  final String imagePath;
  final Color themeColor;

  const ChatView({
    super.key,
    required this.mode,
    required this.imagePath,
    required this.themeColor,
  });

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _localStorageService = LocalStorageService();
  int _remainingRights = 2;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRights();
    _loadBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).loadChatHistory(widget.mode);
    });
  }

  Future<void> _loadRights() async {
    final rights = await _localStorageService.getRemainingRights();
    if (mounted) {
      setState(() {
        _remainingRights = rights;
      });
    }
  }

  void _loadBannerAd() {
    _bannerAd = AdService().createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        print('BannerAd failed to load: $error');
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty && _remainingRights > 0) {
      final text = _textController.text.trim();
      _textController.clear();
      FocusScope.of(context).unfocus(); // Close the keyboard
      _showToneSelectionSheet(context, text);
    }
  }

  void _executeSendMessage(String text, String tone) {
    ref
        .read(chatViewModelProvider.notifier)
        .sendMessage(widget.mode, text, tone);
    _scrollToBottom();
  }

  void _showToneSelectionSheet(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: ColorConstants.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cevap Tarzını Seç',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.titleColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yapay zekanın bu mesaja hangi tonda yanıt vermesini istersiniz?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildToneOptionButton(
                context: context,
                emoji: '😊',
                title: 'Samimi',
                toneKey: 'samimi',
                text: text,
              ),
              const SizedBox(height: 12),
              _buildToneOptionButton(
                context: context,
                emoji: '😒',
                title: 'Pasif-Agresif',
                toneKey: 'pasif agrasif',
                text: text,
              ),
              const SizedBox(height: 12),
              _buildToneOptionButton(
                context: context,
                emoji: '🥰',
                title: 'Sevecen Cana Yakın',
                toneKey: 'sevecen cana yakın',
                text: text,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToneOptionButton({
    required BuildContext context,
    required String emoji,
    required String title,
    required String toneKey,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Close the bottom sheet
        _executeSendMessage(text, toneKey);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  void _watchRewardedAd() {
    AdService().showRewardedAd(
      onRewarded: () async {
        final current = await _localStorageService.getRemainingRights();
        await _localStorageService.setRemainingRights(current + 1);
        _loadRights();
      },
      onAdClosed: () {
        _loadRights();
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotoğraf seçildi! OCR işlemi henüz entegre değil.'),
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Panoya kopyalandı!')));
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sohbet Geçmişini Temizle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bu karakterle olan tüm konuşma geçmişini tamamen sıfırlamak istiyorsun. Bunun için 1 ödüllü reklam izlemen gerekiyor, onaylıyor musun?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ref
                    .read(chatViewModelProvider.notifier)
                    .clearChatHistoryWithReward(widget.mode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.ondemand_video,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Reklam İzle ve Temizle 🎥',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);

    ref.listen<ChatState>(chatViewModelProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      if (previous?.isLoading == true && next.isLoading == false) {
        _loadRights(); // Update rights after AI generates response
      }
    });

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.imagePath),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _remainingRights > 0
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kalan Mesaj Hakkın: $_remainingRights',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearChatDialog,
            tooltip: 'Sohbeti Temizle',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final message = chatState.messages[index];
                  if (message.isUser) {
                    return _buildUserMessage(message.text);
                  } else {
                    return _buildAiMessage(message);
                  }
                },
              ),
            ),
            if (chatState.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            _buildInputArea(),
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFDCF8C6), // WhatsApp light green
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAiMessage(ChatMessageModel message) {
    // Determine text to show. Fallback to option1 if text is empty.
    String textToShow = message.text;
    if (textToShow.isEmpty) {
      textToShow = message.option1 ?? '';
    }

    if (textToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = textToShow.startsWith('Bir hata oluştu:');

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textToShow,
              style: TextStyle(
                color: isError ? Colors.red : Colors.black87,
                fontWeight: isError ? FontWeight.w500 : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _copyToClipboard(textToShow),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      const Text(
                        'Kopyala',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.grey),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: _remainingRights > 0,
              decoration: InputDecoration(
                hintText:
                    _remainingRights > 0
                        ? 'Mesajınızı yazın...'
                        : 'Hakkınız bitti',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          if (_remainingRights > 0)
            CircleAvatar(
              backgroundColor: widget.themeColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _watchRewardedAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              icon: const Icon(
                Icons.ondemand_video,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                '1 Hak İzle 🎥',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
