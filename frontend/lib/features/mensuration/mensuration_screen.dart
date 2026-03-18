import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/parameter_slider.dart';
import 'mensuration_painter.dart';

class MensurationScreen extends StatefulWidget {
  const MensurationScreen({super.key});

  @override
  State<MensurationScreen> createState() => _MensurationScreenState();
}

class _MensurationScreenState extends State<MensurationScreen> with SingleTickerProviderStateMixin {
  String _shape = 'Cuboid';
  double _width = 5.0;
  double _height = 5.0;
  double _depth = 4.0;
  double _radius = 4.0;

  String _unit = 'cm'; // added unit
  double _rotX = 0.0; // added rotation
  double _rotY = 0.0;

  late AnimationController _animController;
  late Animation<double> _anim;

  static const _shapes = ['2D Rect', '2D Circle', '2D Triangle', 'Cuboid', 'Sphere', 'Cone', 'Cylinder', 'Pyramid'];
  static const _units = ['cm', 'm', 'in', 'ft', 'units'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectShape(String s) {
    setState(() => _shape = s);
    _animController.reset();
    _animController.forward();
  }

  void _reset() {
    setState(() { _width = 5; _height = 5; _depth = 4; _radius = 4; _rotX = 0; _rotY = 0; });
    _animController.reset();
    _animController.forward();
  }

  // Computed properties
  String get _primaryFormula {
    switch (_shape) {
      case '2D Rect': return 'Area = w × h';
      case '2D Circle': return 'Area = πr²';
      case '2D Triangle': return 'Area = ½ × b × h';
      case 'Cuboid': return 'Volume = w × h × d';
      case 'Sphere': return 'Volume = (4/3)πr³';
      case 'Cone': return 'Volume = (1/3)πr²h';
      case 'Cylinder': return 'Volume = πr²h';
      case 'Pyramid': return 'Volume = (1/3) × base² × h';
      default: return '';
    }
  }

  Map<String, String> get _measurements {
    final u = _unit;
    switch (_shape) {
      case '2D Rect':
        final area = _width * _height;
        final perim = 2 * (_width + _height);
        return {'Area': '${area.toStringAsFixed(1)} $u²', 'Perimeter': '${perim.toStringAsFixed(1)} $u', 'Diagonal': '${math.sqrt(_width * _width + _height * _height).toStringAsFixed(2)} $u'};
      case '2D Circle':
        final area = math.pi * _radius * _radius;
        final circ = 2 * math.pi * _radius;
        return {'Area': '${area.toStringAsFixed(1)} $u²', 'Circumference': '${circ.toStringAsFixed(1)} $u'};
      case '2D Triangle':
        final area = 0.5 * _width * _height;
        return {'Area': '${area.toStringAsFixed(1)} $u²', 'Base': '${_width.toStringAsFixed(1)} $u', 'Height': '${_height.toStringAsFixed(1)} $u'};
      case 'Cuboid':
        final vol = _width * _height * _depth;
        final sa = 2 * (_width * _height + _height * _depth + _depth * _width);
        return {'Volume': '${vol.toStringAsFixed(1)} $u³', 'Surface Area': '${sa.toStringAsFixed(1)} $u²', 'Diagonal': '${math.sqrt(_width * _width + _height * _height + _depth * _depth).toStringAsFixed(2)} $u'};
      case 'Sphere':
        final vol = (4 / 3) * math.pi * _radius * _radius * _radius;
        final sa = 4 * math.pi * _radius * _radius;
        return {'Volume': '${vol.toStringAsFixed(1)} $u³', 'Surface Area': '${sa.toStringAsFixed(1)} $u²', 'Circumference': '${(2 * math.pi * _radius).toStringAsFixed(1)} $u'};
      case 'Cone':
        final vol = (1 / 3) * math.pi * _radius * _radius * _height;
        final l = math.sqrt(_radius * _radius + _height * _height);
        final sa = math.pi * _radius * (l + _radius);
        return {'Volume': '${vol.toStringAsFixed(1)} $u³', 'Slant Height': '${l.toStringAsFixed(2)} $u', 'Total Surface Area': '${sa.toStringAsFixed(1)} $u²'};
      case 'Cylinder':
        final vol = math.pi * _radius * _radius * _height;
        final sa = 2 * math.pi * _radius * (_height + _radius);
        return {'Volume': '${vol.toStringAsFixed(1)} $u³', 'Curved S.A.': '${(2 * math.pi * _radius * _height).toStringAsFixed(1)} $u²', 'Total S.A.': '${sa.toStringAsFixed(1)} $u²'};
      case 'Pyramid':
        final vol = (1 / 3) * _width * _width * _height;
        final l = math.sqrt((_width / 2) * (_width / 2) + _height * _height);
        final sa = _width * _width + 2 * _width * l;
        return {'Volume': '${vol.toStringAsFixed(1)} $u³', 'Slant Height': '${l.toStringAsFixed(2)} $u', 'Total Surface Area': '${sa.toStringAsFixed(1)} $u²'};
      default: return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return MainLayout(
      title: 'Mensuration — 2D & 3D Shapes',
      actions: [
        IconButton(icon: const Icon(Icons.refresh, color: AppTheme.textSecondary), onPressed: _reset),
      ],
      child: isWide
          ? Row(children: [_buildCanvas(), _buildControls()])
          : SingleChildScrollView(child: Column(children: [_buildCanvas(), _buildControls()])),
    );
  }

  Widget _buildCanvas() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            // Shape chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _shapes.map((s) {
                    final sel = s == _shape;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _selectShape(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.success : AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? AppTheme.success : AppTheme.success.withOpacity(0.25)),
                          ),
                          child: Text(s, style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel ? const Color(0xFF0A0F1E) : AppTheme.success,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Formula chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                ),
                child: Text(_primaryFormula,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            // Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onPanUpdate: (d) {
                    if (!_shape.startsWith('2D')) {
                      setState(() {
                        _rotY += d.delta.dx * 0.01;
                        _rotX -= d.delta.dy * 0.01;
                      });
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, child) => CustomPaint(
                      painter: MensurationPainter(
                        width: _width,
                        height: _height,
                        radius: _radius,
                        depth: _depth,
                        shape: _shape,
                        unit: _unit,
                        rotX: _rotX,
                        rotY: _rotY,
                        animProgress: _anim.value,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return isWide ? Expanded(flex: 3, child: content) : SizedBox(height: 450, child: content);
  }

  Widget _buildControls() {
    final isWide = MediaQuery.of(context).size.width > 800;
    final bool needsRadius = _shape == 'Sphere' || _shape == 'Cone' || _shape == 'Cylinder' || _shape == '2D Circle';
    final bool needsWidth = _shape == '2D Rect' || _shape == 'Cuboid' || _shape == 'Pyramid' || _shape == '2D Triangle';
    final bool needsHeight = _shape != 'Sphere' && _shape != '2D Circle';
    final bool needsDepth = _shape == 'Cuboid';

    return SizedBox(
      width: isWide ? 300 : double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dimensions', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                    _buildUnitDropdown(),
                  ],
                ),
                const SizedBox(height: 16),
                if (needsRadius)
                  ParameterSlider(label: 'Radius (r)', value: _radius, min: 1, max: 10, onChanged: (v) => setState(() => _radius = v)),
                if (needsWidth)
                  ParameterSlider(label: 'Width / Base (w)', value: _width, min: 1, max: 10, onChanged: (v) => setState(() => _width = v)),
                if (needsHeight)
                  ParameterSlider(label: 'Height (h)', value: _height, min: 1, max: 10, onChanged: (v) => setState(() => _height = v)),
                if (needsDepth)
                  ParameterSlider(label: 'Depth (d)', value: _depth, min: 1, max: 10, onChanged: (v) => setState(() => _depth = v)),
                const SizedBox(height: 20),
                _buildAnalysisBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _unit,
          dropdownColor: AppTheme.surfaceLight,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary, size: 16),
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => _unit = newValue);
          },
          items: _units.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAnalysisBox() {
    if (!_shape.startsWith('2D')) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.success.withOpacity(0.2)),
            ),
            child: Column(
              children: _measurements.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    Text(e.value, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.success)),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Tip for interactive drag
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text('Drag shape to rotate 3D view', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
            ],
          )
        ],
      );
    }
    
    // Default 2D
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: Column(
        children: _measurements.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              Text(e.value, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.success)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
