import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screat_app/core/constants/color_constants.dart';
import 'package:screat_app/viewmodels/home_viewmodel.dart';
import 'package:screat_app/views/chat/chat_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Title
            const Text(
              'NE CEVAP\nVEREYİM?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: ColorConstants.titleColor,
                letterSpacing: 2,
                height: 1.1,
                shadows: [
                  Shadow(
                    offset: Offset(2, 3),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Subtitle
            const Text(
              'KİME CEVAP VERİYORSUN?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.subtitleColor,
              ),
            ),
            const SizedBox(height: 25),
            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.80, // Tweak this for card aspect ratio
                  children: [
                    _buildModeCard(
                      ref: ref,
                      modeName: 'PATRON/YÖNETİCİ',
                      imagePath: 'assets/1boss.png',
                      bgColor: ColorConstants.cardBoss,
                      isSelected: selectedMode == 'PATRON/YÖNETİCİ',
                    ),
                    _buildModeCard(
                      ref: ref,
                      modeName: 'SEVGİLİ/FLÖRT',
                      imagePath: 'assets/2date.png',
                      bgColor: ColorConstants.cardDate,
                      isSelected: selectedMode == 'SEVGİLİ/FLÖRT',
                    ),
                    _buildModeCard(
                      ref: ref,
                      modeName: 'PASİF-AGRESİF',
                      imagePath: 'assets/4angry.png',
                      bgColor: ColorConstants.cardPassiveAggressive,
                      isSelected: selectedMode == 'PASİF-AGRESİF',
                    ),
                    _buildModeCard(
                      ref: ref,
                      modeName: 'MÜLAKAT',
                      imagePath: 'assets/3hr.png',
                      bgColor: ColorConstants.cardHr,
                      isSelected: selectedMode == 'MÜLAKAT',
                    ),
                  ],
                ),
              ),
            ),
            // Next Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: ElevatedButton(
                onPressed: selectedMode != null
                    ? () {
                        String imagePath = '';
                        Color themeColor = Colors.blue;
                        
                        if (selectedMode == 'PATRON/YÖNETİCİ') {
                          imagePath = 'assets/1boss.png';
                          themeColor = ColorConstants.cardBoss;
                        } else if (selectedMode == 'SEVGİLİ/FLÖRT') {
                          imagePath = 'assets/2date.png';
                          themeColor = ColorConstants.cardDate;
                        } else if (selectedMode == 'PASİF-AGRESİF') {
                          imagePath = 'assets/4angry.png';
                          themeColor = ColorConstants.cardPassiveAggressive;
                        } else if (selectedMode == 'MÜLAKAT') {
                          imagePath = 'assets/3hr.png';
                          themeColor = ColorConstants.cardHr;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatView(
                              mode: selectedMode,
                              imagePath: imagePath,
                              themeColor: themeColor,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.orangeButton,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'SONRAKİ >',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required WidgetRef ref,
    required String modeName,
    required String imagePath,
    required Color bgColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(homeViewModelProvider.notifier).selectMode(modeName);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 4 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 50, color: Colors.white);
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                modeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
