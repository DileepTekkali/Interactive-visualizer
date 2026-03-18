// FIXED: Removed all API calls - now uses local chemistry calculations
// Issue: Was trying to parse HTML responses as JSON (backend not running)
// Fix: All calculations now performed locally in Dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/services/chemistry_service_local.dart';

class ChangeDetectorScreen extends StatefulWidget {
  const ChangeDetectorScreen({super.key});

  @override
  State<ChangeDetectorScreen> createState() => _ChangeDetectorScreenState();
}

class _ChangeDetectorScreenState extends State<ChangeDetectorScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _result = {};

  void _analyze() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    // FIXED: Using local service instead of API call
    final data = LocalChemistryService.changeDetector(_controller.text.trim());
    setState(() {
      _result = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Physical vs Chemical Change',
      child: isWide
          ? Row(children: [_buildDetector(), _buildExplanation()])
          : SingleChildScrollView(
              child: Column(children: [_buildDetector(), _buildExplanation()])),
    );
  }

  Widget _buildDetector() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text('Describe a scenario:',
                style: GoogleFonts.inter(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Baking a cake, melting ice...',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _analyze(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyze,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Detect Change',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    return isWide
        ? Expanded(flex: 3, child: content)
        : SizedBox(child: content);
  }

  Widget _buildExplanation() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final type = _result['type'] ?? '';
    final explanation = _result['explanation'] ?? '';

    return SizedBox(
      width: isWide ? 400 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: _result.isEmpty
              ? Center(
                  child: Text('Enter a scenario to see the result.',
                      style: GoogleFonts.inter(color: AppTheme.textSecondary)))
              : _result['success'] == false
                  ? Center(
                      child: Text(_result['error'] ?? 'Search failed',
                          style: const TextStyle(color: Colors.redAccent)))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == 'Chemical'
                              ? Icons.science
                              : type == 'Physical'
                                  ? Icons.water_drop
                                  : Icons.help,
                          size: 80,
                          color: type == 'Chemical'
                              ? Colors.redAccent
                              : Colors.lightBlueAccent,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '$type Change',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: type == 'Chemical'
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          explanation.isNotEmpty
                              ? explanation
                              : 'No explanation provided.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 16, color: Colors.white70),
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
