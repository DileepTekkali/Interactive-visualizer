import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class ParameterSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const ParameterSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions = 40,
  });

  @override
  State<ParameterSlider> createState() => _ParameterSliderState();
}

class _ParameterSliderState extends State<ParameterSlider> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submitValue(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(ParameterSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v.toStringAsFixed(1);
  }

  void _submitValue(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null) {
      // Clamping value to min/max prevents the slider from crashing, 
      // but if the user wants an extreme value out of bounds, we can pass it.
      // Since slider requires value to be within min/max, we must clamp
      // OR let the parent handle the actual value but clamp the visual slider.
      // Let's clamp to max/min to keep it safe for the slider widget:
      double safeValue = parsed.clamp(widget.min, widget.max);
      widget.onChanged(safeValue);
      _controller.text = _formatValue(safeValue);
    } else {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(
                width: 60,
                height: 28,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*')),
                  ],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGlow,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    filled: true,
                    fillColor: AppTheme.accent.withOpacity(0.15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.accent),
                    ),
                  ),
                  onSubmitted: _submitValue,
                ),
              ),
            ],
          ),
          Slider(
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: _formatValue(widget.value),
            onChanged: (v) {
              _controller.text = _formatValue(v);
              widget.onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
