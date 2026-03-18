import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'data_handling_painter.dart';

class DataHandlingScreen extends StatefulWidget {
  const DataHandlingScreen({super.key});

  @override
  State<DataHandlingScreen> createState() => _DataHandlingScreenState();
}

class _DataHandlingScreenState extends State<DataHandlingScreen> with SingleTickerProviderStateMixin {
  final List<double> _values = [5.0, 7.0, 3.0, 8.0, 6.0];
  final List<String> _categories = ['A', 'B', 'C', 'D', 'E'];
  
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      for (int i = 0; i < _values.length; i++) {
        _values[i] = 5.0;
      }
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MainLayout(
      title: 'Data Handling',
      actions: [
        IconButton(icon: const Icon(Icons.refresh, color: AppTheme.textSecondary), onPressed: _reset),
        const SizedBox(width: 8),
      ],
      child: isWide
          ? Row(children: [_buildChart(), _buildControls()])
          : SingleChildScrollView(child: Column(children: [_buildChart(), _buildControls()])),
    );
  }

  Widget _buildChart() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Interactive Bar Chart', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) => CustomPaint(
                    painter: DataHandlingPainter(values: _values, categories: _categories, animProgress: _anim.value),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 400, child: content);
  }

  Widget _buildControls() {
    final isWide = MediaQuery.of(context).size.width > 800;
    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categories', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ...List.generate(_values.length, (index) {
                return ParameterSlider(
                  label: 'Category ${_categories[index]}',
                  value: _values[index],
                  min: 0,
                  max: 10,
                  onChanged: (v) => setState(() => _values[index] = v),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
