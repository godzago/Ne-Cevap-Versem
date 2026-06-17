import 'package:flutter/material.dart';
import 'package:screat_app/core/constants/color_constants.dart';
import 'package:screat_app/data/services/local_storage_service.dart';
import 'package:screat_app/views/home/home_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _storageService = LocalStorageService();
  String? _selectedGender; // 'MALE' or 'FEMALE'
  bool _isSaving = false;

  Future<void> _completeOnboarding() async {
    if (_selectedGender == null) return;
    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.setUserGender(_selectedGender!);
      await _storageService.setOnboardingCompleted(true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Title
              const Text(
                'NE CEVAP\nVEREYİM?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: ColorConstants.titleColor,
                  letterSpacing: 2,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 3),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'HOŞ GELDİNİZ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.subtitleColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sanal asistanımızın size en uygun hitap tarzıyla alternatif cevaplar üretebilmesi için lütfen cinsiyetinizi seçin:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Gender cards side-by-side
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard(
                      gender: 'MALE',
                      label: 'Erkek',
                      icon: Icons.male,
                      color: const Color(0xFF90CAF9),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildGenderCard(
                      gender: 'FEMALE',
                      label: 'Kadın',
                      icon: Icons.female,
                      color: const Color(0xFFFFCDD2),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Next Button
              if (_selectedGender != null)
                AnimatedOpacity(
                  opacity: _selectedGender != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.orangeButton,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'BAŞLA >',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 68), // Spacer to avoid layout jump
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required String gender,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 4 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 15 : 8,
              offset: isSelected ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
